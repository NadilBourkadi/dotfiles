return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("render-markdown").setup({})

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
th { background: #f4f4f4; }]]

    local function html_path_for(abs)
      local hash = vim.fn.sha256(abs)
      return preview_dir .. "/" .. hash:sub(1, 12) .. ".html"
    end

    --- Convert a markdown file to HTML preview. Returns the output path, or nil on error.
    local function generate_html(abs)
      local body = vim.fn.system("pandoc -f gfm -t html " .. vim.fn.shellescape(abs))
      if vim.v.shell_error ~= 0 then
        vim.notify("pandoc failed: " .. body, vim.log.levels.ERROR)
        return nil
      end
      local html = "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><style>\n"
        .. css
        .. "\n</style></head><body>"
        .. body
        .. "</body></html>"
      vim.fn.mkdir(preview_dir, "p")
      local out = html_path_for(abs)
      local f = io.open(out, "w")
      if not f then
        vim.notify("Failed to write " .. out, vim.log.levels.ERROR)
        return nil
      end
      f:write(html)
      f:close()
      return out
    end

    vim.keymap.set("n", "<leader>mp", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle markdown preview" })
    vim.keymap.set("n", "<leader>mh", function()
      local src = vim.api.nvim_buf_get_name(0)
      if src == "" or vim.bo.filetype ~= "markdown" then
        vim.notify("Not a markdown file", vim.log.levels.WARN)
        return
      end

      local abs = vim.fn.fnamemodify(src, ":p")
      local out = generate_html(abs)
      if not out then return end

      if previewed_path ~= abs then
        previewed_path = abs
        vim.ui.open(out)

        -- Set up autocmd to regenerate HTML on save
        vim.api.nvim_clear_autocmds({ group = augroup })
        vim.api.nvim_create_autocmd("BufWritePost", {
          group = augroup,
          pattern = abs,
          callback = function()
            generate_html(abs)
          end,
        })
      end
    end, { desc = "Preview markdown as HTML in browser" })
  end,
}
