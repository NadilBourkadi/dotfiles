-- Diffview configuration
-- Side-by-side branch diff and file history for code review

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    { "<leader>gv", "<cmd>DiffviewOpen<CR>", desc = "Diff branch" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Branch history" },
    { "<leader>gm", "<cmd>DiffviewOpen master<CR>", desc = "Diff against master" },
    { "<leader>gc", "<cmd>DiffviewClose<CR>", desc = "Close diffview" },
  },
}
