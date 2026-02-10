-- GitHub Copilot - AI autocomplete
return {
  "github/copilot.vim",
  event = "InsertEnter",
  config = function()
    -- Disable Copilot's default Tab mapping so nvim-cmp can handle Tab
    vim.g.copilot_no_tab_map = true
  end,
}
