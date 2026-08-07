-- Lualine configuration
-- Replaces lightline.vim

return {
  "nvim-lualine/lualine.nvim",
  -- catppuccin is a dependency, not just a colour source: the theme module
  -- reads require("catppuccin").options at load time, so setup() must have
  -- already run. Today priority = 1000 happens to guarantee that; declaring
  -- it keeps that true if lualine ever gains a lazy-load trigger.
  dependencies = { "echasnovski/mini.icons", "catppuccin/nvim" },
  config = function()
    require("lualine").setup({
      options = {
        -- Upstream renamed lua/lualine/themes/catppuccin.lua to catppuccin-nvim.lua
        theme = "catppuccin-nvim",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          "diff",
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
          },
        },
        lualine_c = {
          {
            "filename",
            path = 1,
            symbols = {
              modified = "[+]",
              readonly = "[-]",
              unnamed = "[No Name]",
            },
          },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { "nvim-tree", "fugitive", "quickfix" },
    })
  end,
}
