-- Treesitter configuration for Neovim 0.11+
-- Neovim 0.11 has built-in treesitter, this plugin adds parser management

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  config = function()
    local ts = require("nvim-treesitter")
    ts.setup({})

    -- Parsers to auto-install
    local ensure_installed = {
      "lua", "python", "javascript", "typescript", "tsx",
      "json", "yaml", "toml", "bash", "html", "css",
      "markdown", "markdown_inline", "vim", "vimdoc",
    }

    -- Install parsers asynchronously (new API - no-op if already installed)
    ts.install(ensure_installed)

    -- Enable treesitter-based highlighting (Neovim 0.11+ native)
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
