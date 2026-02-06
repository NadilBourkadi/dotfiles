-- Plugin specifications for lazy.nvim
-- This file returns a table of all plugin specs

return {
  -- Import individual plugin configs
  { import = "plugins.catppuccin" },
  { import = "plugins.telescope" },
  { import = "plugins.nvim-tree" },
  { import = "plugins.lsp" },
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

  -- Plugins that work with minimal or no config

  -- Icons (mini.icons as nvim-web-devicons replacement)
  {
    "echasnovski/mini.icons",
    lazy = false,
    config = function()
      require("mini.icons").setup()
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
      local wk = require("which-key")
      wk.setup({})
      wk.add({
        { "<leader>c", group = "Quickfix/Calls" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git Hunks" },
        { "<leader>i", group = "Inlay Hints" },
        { "<leader>n", group = "Neogen" },
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
