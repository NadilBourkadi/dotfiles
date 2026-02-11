return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("render-markdown").setup({})

    vim.keymap.set("n", "<leader>mp", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle markdown preview" })
    vim.keymap.set("n", "<leader>mh", function()
      local src = vim.api.nvim_buf_get_name(0)
      local tmp = vim.fn.tempname() .. ".html"
      vim.fn.system("pandoc " .. vim.fn.shellescape(src) .. " -o " .. vim.fn.shellescape(tmp))
      vim.ui.open(tmp)
    end, { desc = "Open markdown as HTML in browser" })
  end,
}
