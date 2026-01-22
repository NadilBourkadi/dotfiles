-- GitHub Copilot - AI autocomplete
return {
  "github/copilot.vim",
  lazy = false,
  config = function()
    -- Accept suggestion with Tab (default is Tab but being explicit)
    vim.g.copilot_assume_mapped = true

    -- Disable for certain filetypes if needed
    vim.g.copilot_filetypes = {
      ["*"] = true,
      ["markdown"] = true,
      ["yaml"] = true,
    }
  end,
}
