-- Code formatting with conform.nvim

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
        json = { "prettier" },
      },
      format_after_save = {
        lsp_fallback = true,
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>pp", function()
      require("conform").format({ async = true, lsp_fallback = true })
    end)
  end,
}
