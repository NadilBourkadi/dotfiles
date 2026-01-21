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
  { import = "plugins.lualine" },
  { import = "plugins.neotest" },
  { import = "plugins.ufo" },

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
  { "tpope/vim-fugitive" },

  -- JSDoc generation
  { "joegesualdo/jsdoc.vim" },

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
    opts = {},
  },
}
