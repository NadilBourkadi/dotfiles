-- dressing.nvim configuration
-- Improves vim.ui.input() and vim.ui.select() UI

return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  config = function()
    require("dressing").setup({
      input = {
        enabled = true,
        default_prompt = "Input:",
        title_pos = "left",
        insert_only = true,
        start_in_insert = true,
        border = "rounded",
        relative = "cursor",
        prefer_width = 40,
        width = nil,
        max_width = { 140, 0.9 },
        min_width = { 20, 0.2 },
        win_options = {
          winblend = 0,
          wrap = false,
        },
      },
      select = {
        enabled = true,
        backend = { "telescope", "builtin" },
        trim_prompt = true,
        telescope = nil,
        builtin = {
          show_numbers = true,
          border = "rounded",
          relative = "editor",
          win_options = {
            winblend = 0,
          },
          width = nil,
          max_width = { 140, 0.8 },
          min_width = { 40, 0.2 },
          height = nil,
          max_height = 0.9,
          min_height = { 10, 0.2 },
        },
      },
    })
  end,
}
