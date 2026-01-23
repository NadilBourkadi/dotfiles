-- indent-blankline.nvim configuration
-- Shows vertical indent guides

return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    -- Subtle scope highlight (between inactive and bright)
    vim.api.nvim_set_hl(0, "IblScopeSubtle", { fg = "#7f849c" }) -- Catppuccin overlay1

    require("ibl").setup({
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
        highlight = { "IblScopeSubtle" },
        include = {
          node_type = {
            lua = { "table_constructor" },
            python = { "dictionary", "list" },
            javascript = { "object", "array" },
            typescript = { "object", "array" },
            json = { "object", "array" },
          },
        },
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "NvimTree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    })
  end,
}
