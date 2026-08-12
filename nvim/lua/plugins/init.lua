-- Plugin specifications for lazy.nvim
-- This file returns a table of all plugin specs

return {
  -- Import individual plugin configs
  { import = "plugins.catppuccin" },
  { import = "plugins.telescope" },
  { import = "plugins.nvim-tree" },
  { import = "plugins.lsp" },
  { import = "plugins.completion" },
  { import = "plugins.formatting" },
  { import = "plugins.treesitter" },
  { import = "plugins.gitsigns" },
  { import = "plugins.diffview" },
  { import = "plugins.open-on-github" },
  { import = "plugins.lualine" },
  { import = "plugins.vim-test" },
  { import = "plugins.ufo" },
  { import = "plugins.copilot" },
  { import = "plugins.bufferline" },
  { import = "plugins.persistence" },
  { import = "plugins.dap" },
  { import = "plugins.neogen" },
  { import = "plugins.lint" },
  { import = "plugins.luasnip" },
  { import = "plugins.coverage" },
  { import = "plugins.signature" },
  { import = "plugins.render-markdown" },

  -- Plugins that work with minimal or no config

  -- Icons (mini.icons as nvim-web-devicons replacement)
  {
    "echasnovski/mini.icons",
    lazy = false,
    config = function()
      local icons = require("core.icons")
      local mini = require("mini.icons")

      -- Most of mini.icons' set is Plane-15, which Alacritty renders two cells
      -- wide against Neovim's one -- see core/icons.lua. Two passes because
      -- there is no accessor for the defaults: set it up bare, read what each
      -- name resolves to, then set it up again with the offenders replaced.
      mini.setup()

      -- Fallback for the ~1050 swept glyphs, per category.
      local fallbacks = {
        default = "\u{F016}", -- fa-file_o
        directory = "\u{E5FF}", -- custom-folder
        extension = "\u{F016}",
        file = "\u{F016}",
        filetype = "\u{F016}",
        lsp = "\u{EA72}", -- cod-primitive_square
        os = "\u{EA72}",
      }

      -- Keep a distinct glyph for the types actually edited on this machine.
      -- csv, sh, zsh, toml, yml, README.md and LICENSE are already basic-plane
      -- upstream, so the sweep leaves them alone and they need no entry here.
      local curated = {
        extension = {
          md = "\u{E609}", -- seti-markdown
          lua = "\u{E620}", -- seti-lua
          py = "\u{E606}", -- seti-python
          json = "\u{E80B}", -- dev-json
          txt = "\u{E64E}", -- seti-text
          log = "\u{F4ED}", -- oct-log
          conf = "\u{E615}", -- seti-config
          tmux = "\u{E615}",
          html = "\u{E736}", -- dev-html5
          css = "\u{E749}", -- dev-css3
          js = "\u{E60C}", -- seti-javascript
          ts = "\u{E628}", -- seti-typescript
          sql = "\u{E706}", -- dev-database
          pdf = "\u{F1C1}", -- fa-file_pdf_o
          png = "\u{F1C5}", -- fa-file_picture_o
          jpg = "\u{F1C5}",
          jpeg = "\u{F1C5}",
          svg = "\u{F1C5}",
          gz = "\u{F1C6}", -- fa-file_zipper
          zip = "\u{F1C6}",
          tar = "\u{F1C6}",
        },
        file = {
          [".gitignore"] = "\u{E65D}", -- seti-git_ignore
          ["Brewfile"] = "\u{F0FC}", -- fa-beer_mug_empty
          ["Makefile"] = "\u{E673}", -- seti-makefile
          ["tmux.conf"] = "\u{E615}", -- seti-config
        },
      }

      local overrides = {}
      for category, fallback in pairs(fallbacks) do
        local entries = {}
        for _, name in ipairs(mini.list(category)) do
          local glyph, hl = mini.get(category, name)
          if icons.is_wide(glyph) then
            -- The "default" category lists the *other* category names, and its
            -- entries are each one's fallback icon -- so there the glyph is
            -- chosen by name, not by the category being swept. Getting this
            -- wrong gives every unknown directory a file icon. Keyed only for
            -- that category, since a filetype could be named "file" or "os".
            local pick = fallback
            if category == "default" then
              pick = fallbacks[name] or fallback
            end
            entries[name] = { glyph = pick, hl = hl }
          end
        end
        overrides[category] = entries
      end

      -- Applied after the sweep, and without consulting mini.list(): "md" is
      -- not in the extension table -- it resolves through the filetype one --
      -- but an override for it still registers. Keep the resolved highlight so
      -- only the glyph changes.
      for category, entries in pairs(curated) do
        overrides[category] = overrides[category] or {}
        for name, glyph in pairs(entries) do
          local _, hl = mini.get(category, name)
          overrides[category][name] = { glyph = glyph, hl = hl }
        end
      end

      mini.setup(overrides)

      MiniIcons.mock_nvim_web_devicons()
    end,
  },

  -- Git integration (keeping vim-fugitive - it's excellent)
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiff", "Gblame" },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "Git status" },
      { "<leader>gd", "<cmd>Gdiff<CR>", desc = "Git diff" },
      { "<leader>gb", "<cmd>Git blame<CR>", desc = "Git blame" },
      { "<leader>gl", "<cmd>Git log --oneline<CR>", desc = "Git log" },
    },
  },

  -- JSDoc generation (lazy-load for JS/TS files only)
  { "joegesualdo/jsdoc.vim", ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" } },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- Which-key for discovering keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local icons = require("core.icons")
      local wk = require("which-key")
      local SQUARE = "\u{EA72}" -- cod-primitive_square

      -- which-key's key glyphs are Plane-15 -- Space is U+F1050, the Ctrl/Alt/
      -- Shift/Cmd modifiers are U+F0633-6, F1-F12 are U+F12AB+ -- so any row
      -- for one of those keys shifts from that column on. (The leader here is
      -- `,`, so leader rows are not themselves affected.) See core/icons.lua.
      --
      -- These must go in a *single* setup() call. which-key's load() is
      -- deferred and closes over the opts of the call that scheduled it; the
      -- first load to run rebuilds options as
      -- `defaults + preset + its own opts` and sets `M.loaded`, so a later
      -- setup's opts are discarded entirely. Since opts are merged last, one
      -- call's overrides do survive the preset rebuild.
      --
      -- Text rather than glyphs: view.lua substitutes these *in place of* the
      -- key name, so one shared fallback would render <C-x>, <M-x> and <S-x>
      -- identically. There is no basic-plane set that keeps 24 keys distinct.
      local keys = {
        C = "C-",
        M = "M-",
        D = "D-",
        S = "S-",
        CR = "CR ",
        NL = "NL ",
        Esc = "Esc ",
        BS = "BS ",
        Space = "Space ",
        Tab = "Tab ",
        ScrollWheelDown = "ScrollDn ",
        ScrollWheelUp = "ScrollUp ",
      }
      for i = 1, 12 do
        keys["F" .. i] = "F" .. i .. " "
      end
      wk.setup({ icons = { keys = keys } })

      -- The glyphs which-key resolves outside `icons.keys` have to be demoted
      -- in place, because neither is replaceable through setup(). Reaching
      -- into upstream internals like this must never abort config(), which
      -- would take the wk.add() group labels below with it -- hence the pcall.
      local swept = pcall(function()
        -- icons.get() always falls back to this built-in table; passing
        -- `icons.rules` only adds one that is consulted first.
        for _, rule in ipairs(require("which-key.icons").rules) do
          if type(rule.icon) == "string" then
            rule.icon = icons.demote_string(rule.icon, SQUARE)
          end
        end
        -- The built-in plugins (marks, registers) carry an icon on their
        -- mapping spec, at `M.mappings.icon.icon`, which view.icon() returns
        -- verbatim -- bypassing both rules tables. Swapping the field now is
        -- enough: plugins.setup() later reads it off the same cached module.
        for name in pairs(require("which-key.config").plugins or {}) do
          local ok, plugin = pcall(require, "which-key.plugins." .. name)
          if ok and type(plugin) == "table" and type(plugin.mappings) == "table" then
            plugin.mappings = icons.demoted(plugin.mappings, SQUARE)
          end
        end
      end)

      -- Nothing upstream validates any of this, so assert it instead of
      -- trusting it: a new key label or a renamed table would otherwise bring
      -- the misalignment back with no warning at all. which-key loads on
      -- VeryLazy, which is after VimEnter, so its deferred load() is already
      -- queued and a schedule here lands after it.
      vim.schedule(function()
        local resolved = vim.tbl_get(require("which-key.config"), "options", "icons")
        local residual = {}
        if resolved then
          for name, glyph in pairs(resolved.keys or {}) do
            if icons.is_wide(glyph) then
              residual[#residual + 1] = "keys." .. name
            end
          end
        end
        if not swept or not resolved or #residual > 0 then
          -- Kept to one short line on purpose: a message wider than the command
          -- line raises a blocking hit-enter prompt, and this fires at startup.
          local detail = resolved and table.concat(residual, ",") or "icons missing"
          vim.notify(
            "which-key: Plane-15 glyphs remain (" .. (swept and detail or detail .. ",sweep failed") .. ")",
            vim.log.levels.WARN
          )
        end
      end)
      wk.add({
        { "<leader>c", group = "Quickfix/Calls" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git Hunks" },
        { "<leader>i", group = "Inlay Hints" },
        { "<leader>m", group = "Markdown" },
        { "<leader>a", group = "Annotate" },
        { "<leader>n", group = "NvimTree" },
        { "<leader>p", group = "Plugins/Format" },
        { "<leader>q", group = "Quit" },
        { "<leader>r", group = "Rename/Restart" },
        { "<leader>s", group = "Search/Session" },
        { "<leader>t", group = "Test/Toggle" },
        { "<leader>T", group = "Coverage" },
        { "<leader>x", group = "Diagnostics" },
      })
    end,
  },
}
