-- Test runner configuration
-- Using vim-test for stability

return {
  "vim-test/vim-test",
  config = function()
    vim.g["test#strategy"] = "neovim"

    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    map("n", "<leader>tn", "<cmd>TestNearest<CR>", opts)
    map("n", "<leader>tt", "<cmd>TestFile<CR>", opts)
    map("n", "<leader>ts", "<cmd>TestSuite<CR>", opts)
    map("n", "<leader>tl", "<cmd>TestLast<CR>", opts)
    map("n", "<leader>tv", "<cmd>TestVisit<CR>", opts)
  end,
}
