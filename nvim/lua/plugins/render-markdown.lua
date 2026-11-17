return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local icons = require("core.icons")
    local rm = require("render-markdown")

    -- Every icon render-markdown ships is Plane-15, which Alacritty renders
    -- two cells wide against Neovim's one -- see core/icons.lua. The sign is
    -- the worst of them: it sits in the two-cell sign column, so its overflow
    -- shifts the whole line and a table's header stops lining up with its
    -- body. Sweep the defaults, then name the ones worth keeping distinct.
    --
    -- Only the sections that actually carry an icon are passed back in.
    -- setup() merges user config over the defaults, so handing it a full copy
    -- would pin today's values for every unrelated option too -- upstream
    -- could never change one again.
    local swept = icons.demoted_sections(rm.default, "\u{F05A}") -- fa-info_circle
    rm.setup(vim.tbl_deep_extend("force", swept, {
      heading = {
        -- One marker per level, matching the bullet style. There is no h1-h6
        -- set outside Plane-15, so these are geometric shapes.
        icons = {
          "\u{25C9} ", -- ◉
          "\u{25CB} ", -- ○
          "\u{25CF} ", -- ●
          "\u{25A0} ", -- ■
          "\u{25C6} ", -- ◆
          "\u{25C7} ", -- ◇
        },
        signs = { "\u{F4E0} " }, -- oct-heading
      },
      checkbox = {
        checked = { icon = "\u{E63F} " }, -- seti-checkbox
        unchecked = { icon = "\u{E640} " }, -- seti-checkbox_unchecked
      },
      link = {
        hyperlink = "\u{EB15} ", -- cod-link
        email = "\u{F0E0} ", -- fa-envelope
        image = "\u{F03E} ", -- fa-picture_o
      },
      -- Cells are padded to the widest in the column by default, so a table
      -- holding one very long cell wraps every row over many screen lines.
      pipe_table = { cell = "trimmed" },
    }))

    local preview_dir = "/tmp/nvim-md-preview"
    local previewed_path = nil
    local augroup = vim.api.nvim_create_augroup("MdHtmlPreview", { clear = true })

    local css = [[
body { font-family: -apple-system, system-ui, sans-serif; max-width: 800px; margin: 40px auto; padding: 0 20px; line-height: 1.6; color: #333; }
code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; font-size: 0.9em; }
pre { background: #f4f4f4; padding: 16px; border-radius: 6px; overflow-x: auto; }
pre code { background: none; padding: 0; }
blockquote { border-left: 4px solid #ddd; margin-left: 0; padding-left: 16px; color: #666; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
th { background: #f4f4f4; }
img { max-width: 100%; height: auto; }]]

    local function html_path_for(abs)
      local hash = vim.fn.sha256(abs)
      return preview_dir .. "/" .. hash:sub(1, 12) .. ".html"
    end

    -- Minimal page shell: pandoc's default template would add its own CSS and
    -- demand a title. Standalone mode is still needed for --embed-resources.
    local template = "<!DOCTYPE html><html><head><meta charset=\"utf-8\">"
      .. "$for(header-includes)$$header-includes$$endfor$</head><body>$body$</body></html>\n"

    local jobs = {} -- markdown path -> latest in-flight pandoc run

    local function write_file(path, contents)
      local f = io.open(path, "w")
      if not f then return false end
      f:write(contents)
      f:close()
      return true
    end

    --- Convert a markdown file to an HTML preview. Runs pandoc asynchronously --
    --- --embed-resources fetches remote images, which must not block the editor
    --- on every save -- and calls on_done(out) once the page is written.
    --- Images are inlined as data URIs (resolved relative to the markdown file), so
    --- they render from the preview dir and survive copy-paste into other tools.
    local function generate_html(abs, on_done)
      vim.fn.mkdir(preview_dir, "p")
      local template_path = preview_dir .. "/template.html"
      local style_path = preview_dir .. "/style.html"
      if not write_file(template_path, template) or not write_file(style_path, "<style>\n" .. css .. "\n</style>") then
        vim.notify("Failed to write preview support files in " .. preview_dir, vim.log.levels.ERROR)
        return
      end

      local out = html_path_for(abs)
      local cmd = {
        "pandoc", "-f", "gfm", "-t", "html",
        "--standalone", "--embed-resources",
        "--template", template_path,
        "-H", style_path,
        "--resource-path", vim.fn.fnamemodify(abs, ":h"),
        "-o", out,
        abs,
      }
      -- A run stuck fetching a remote image can finish after a newer one, so
      -- kill the previous run for this file and ignore whatever it reports.
      if jobs[abs] then jobs[abs]:kill("sigterm") end
      local job
      job = vim.system(cmd, { text = true }, vim.schedule_wrap(function(res)
        if jobs[abs] ~= job then return end
        jobs[abs] = nil
        local stderr = vim.trim(res.stderr or "")
        if res.code ~= 0 then
          vim.notify("pandoc failed: " .. stderr, vim.log.levels.ERROR)
          return
        end
        if stderr ~= "" then
          -- e.g. an image that couldn't be fetched; the page is still written.
          -- Keep only pandoc's [WARNING] lines -- an HTTP failure adds a long
          -- error dump after each one.
          local warnings = {}
          for line in stderr:gmatch("[^\n]+") do
            if line:match("^%[WARNING%]") then table.insert(warnings, line) end
          end
          vim.notify("pandoc: " .. (#warnings > 0 and table.concat(warnings, "\n") or stderr:match("[^\n]+")),
            vim.log.levels.WARN)
        end
        if on_done then on_done(out) end
      end))
      jobs[abs] = job
    end

    vim.keymap.set("n", "<leader>mp", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle markdown preview" })
    vim.keymap.set("n", "<leader>mh", function()
      local src = vim.api.nvim_buf_get_name(0)
      if src == "" or vim.bo.filetype ~= "markdown" then
        vim.notify("Not a markdown file", vim.log.levels.WARN)
        return
      end

      local abs = vim.fn.fnamemodify(src, ":p")
      if previewed_path == abs then
        generate_html(abs)
        return
      end

      generate_html(abs, function(out)
        local ok, err = pcall(vim.ui.open, out)
        if not ok then
          vim.notify("Failed to open browser: " .. tostring(err), vim.log.levels.ERROR)
          return
        end
        previewed_path = abs

        -- Set up autocmd to regenerate HTML on save
        vim.api.nvim_clear_autocmds({ group = augroup })
        vim.api.nvim_create_autocmd("BufWritePost", {
          group = augroup,
          pattern = abs,
          callback = function()
            generate_html(abs)
          end,
        })
      end)
    end, { desc = "Preview markdown as HTML in browser" })
  end,
}
