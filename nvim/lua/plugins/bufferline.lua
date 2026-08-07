-- Bufferline for prominent tab display
return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "catppuccin/nvim" },
  config = function()
    -- Catppuccin moved bufferline out of `integrations` into this module.
    -- Guarded: upstream renames this sort of thing, and a bare require here
    -- would abort setup() and leave no tabline at all rather than fall back
    -- to bufferline's own colours.
    local ok, ctp = pcall(require, "catppuccin.special.bufferline")

    require("bufferline").setup({
      highlights = ok and ctp.get_theme() or nil,
      options = {
        mode = "tabs", -- Show actual tabs, not buffers
        separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    })
  end,
}
