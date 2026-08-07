-- Catppuccin colorscheme configuration
-- Replaces lucius from vimrc

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      transparent_background = true,
      term_colors = true,
      -- Must be passed explicitly: catppuccin tests the raw user table for
      -- this key before merging its own defaults, so the documented default
      -- of `true` never actually enables detection.
      auto_integrations = true,
      -- Replaces the removed `integrations.native_lsp`; underlines default
      -- to "underline" upstream.
      lsp_styles = {
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
          ok = { "undercurl" },
        },
      },
    })
    vim.cmd.colorscheme("catppuccin-nvim")
  end,
}
