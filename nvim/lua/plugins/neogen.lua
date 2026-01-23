-- Docstring generation
-- Google-style docstrings for Python

return {
  "danymat/neogen",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<leader>nf", "<cmd>Neogen func<CR>", desc = "Generate function docstring" },
    { "<leader>nc", "<cmd>Neogen class<CR>", desc = "Generate class docstring" },
  },
  config = function()
    require("neogen").setup({
      enabled = true,
      languages = {
        python = {
          template = {
            annotation_convention = "google_docstrings",
          },
        },
      },
    })
  end,
}
