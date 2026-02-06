-- GitHub Copilot - AI autocomplete
return {
  "github/copilot.vim",
  event = "InsertEnter",
  config = function()
    -- Accept suggestion with Tab (default is Tab but being explicit)
    vim.g.copilot_assume_mapped = true
  end,
}
