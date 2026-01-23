-- Source/Test file switching
-- Patterns for sara_api: sara_api/handlers/foo.py <-> tests/unittests/handlers/test_foo.py

return {
  "rgroli/other.nvim",
  keys = {
    { "<leader>oo", "<cmd>Other<CR>", desc = "Switch to other file" },
    { "<leader>os", "<cmd>OtherSplit<CR>", desc = "Other in split" },
    { "<leader>ov", "<cmd>OtherVSplit<CR>", desc = "Other in vsplit" },
  },
  config = function()
    require("other-nvim").setup({
      mappings = {
        -- sara_api patterns
        {
          pattern = "sara_api/(.*)/(.*)%.py$",
          target = "tests/unittests/%1/test_%2.py",
        },
        {
          pattern = "tests/unittests/(.*)/test_(.*)%.py$",
          target = "sara_api/%1/%2.py",
        },
        -- Generic Python patterns (fallback)
        {
          pattern = "(.*)%.py$",
          target = "tests/test_%1.py",
        },
        {
          pattern = "tests/test_(.*)%.py$",
          target = "%1.py",
        },
      },
    })
  end,
}
