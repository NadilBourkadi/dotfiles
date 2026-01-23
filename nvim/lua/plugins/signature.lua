-- Function signature help
-- Shows parameter hints while typing function arguments

return {
  "ray-x/lsp_signature.nvim",
  event = "LspAttach",
  config = function()
    require("lsp_signature").setup({
      bind = true,
      handler_opts = {
        border = "rounded",
      },
      hint_enable = true,
      hint_prefix = "󰏪 ",
      floating_window = true,
      floating_window_above_cur_line = true,
      toggle_key = "<C-s>",
    })
  end,
}
