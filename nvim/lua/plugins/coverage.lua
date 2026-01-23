-- Test coverage display
-- Show coverage in gutter after running pytest with --cov

return {
  "andythigpen/nvim-coverage",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>Tc", "<cmd>CoverageToggle<CR>", desc = "Toggle coverage" },
    { "<leader>Ts", "<cmd>CoverageSummary<CR>", desc = "Coverage summary" },
    { "<leader>Tl", "<cmd>CoverageLoad<CR>", desc = "Load coverage" },
  },
  config = function()
    require("coverage").setup({
      auto_reload = true,
      lang = {
        python = {
          coverage_file = ".coverage",
        },
      },
      signs = {
        covered = { hl = "CoverageCovered", text = "▎" },
        uncovered = { hl = "CoverageUncovered", text = "▎" },
      },
      highlights = {
        covered = { fg = "#a6e3a1" },
        uncovered = { fg = "#f38ba8" },
      },
    })
  end,
}
