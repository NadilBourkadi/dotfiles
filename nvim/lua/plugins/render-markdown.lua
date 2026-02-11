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
      local body = vim.fn.system("pandoc -f gfm -t html " .. vim.fn.shellescape(src))
      local html = [[<!DOCTYPE html><html><head><meta charset="utf-8"><style>
body { font-family: -apple-system, system-ui, sans-serif; max-width: 800px; margin: 40px auto; padding: 0 20px; line-height: 1.6; color: #333; }
code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; font-size: 0.9em; }
pre { background: #f4f4f4; padding: 16px; border-radius: 6px; overflow-x: auto; }
pre code { background: none; padding: 0; }
blockquote { border-left: 4px solid #ddd; margin-left: 0; padding-left: 16px; color: #666; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
th { background: #f4f4f4; }
</style></head><body>]] .. body .. [[</body></html>]]
      local out = vim.fn.tempname() .. ".html"
      local f = io.open(out, "w")
      f:write(html)
      f:close()
      vim.ui.open(out)
    end, { desc = "Open markdown as HTML in browser" })
  end,
}
