-- Treesitter configuration for Neovim 0.11+
-- Neovim 0.11 has built-in treesitter, this plugin adds parser management

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    -- Enable treesitter-based highlighting (Neovim 0.11+ native)
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
