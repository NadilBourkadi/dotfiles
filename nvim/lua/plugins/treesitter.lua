-- Treesitter configuration for Neovim 0.11+
-- Neovim 0.11 has built-in treesitter, this plugin adds parser management

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    -- Install parsers
    local ensure_installed = {
      "lua", "vim", "vimdoc", "python", "javascript", "typescript",
      "json", "html", "css", "bash", "yaml", "markdown",
    }

    -- Use vim.schedule to avoid blocking startup
    vim.schedule(function()
      local ok, install = pcall(require, "nvim-treesitter.install")
      if ok and install.ensure_installed then
        install.ensure_installed(ensure_installed)
      end
    end)

    -- Enable treesitter-based highlighting (Neovim 0.11+ native)
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
