-- Test runner configuration
-- Using vim-test for stability

return {
  "vim-test/vim-test",
  config = function()
    vim.g["test#strategy"] = "neovim"
    -- Open terminal at bottom with 1/3 screen height
    vim.g["test#neovim#term_position"] = "botright " .. math.floor(vim.o.lines / 3)
    -- Stay in normal mode after test finishes (allows scrolling without closing)
    vim.g["test#neovim#start_normal"] = 1

    -- Pytest: disable output capture for immediate feedback, shorter tracebacks
    vim.g["test#python#pytest#options"] = "-s --tb=short -v --no-header"

    -- Close existing test terminal before running new test
    local function close_test_terminal()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" then
          local name = vim.api.nvim_buf_get_name(buf)
          if name:match("test") or name:match("jest") or name:match("pytest") or name:match("go test") or name:match("cargo test") then
            vim.api.nvim_win_close(win, true)
          end
        end
      end
    end

    local function run_test(cmd)
      close_test_terminal()
      vim.notify("Running tests...", vim.log.levels.INFO)
      vim.cmd(cmd)
    end

    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    map("n", "<leader>tn", function() run_test("TestNearest") end, opts)
    map("n", "<leader>tt", function() run_test("TestFile") end, opts)
    map("n", "<leader>ts", function() run_test("TestSuite") end, opts)
    map("n", "<leader>tl", function() run_test("TestLast") end, opts)
    map("n", "<leader>tv", "<cmd>TestVisit<CR>", opts)
    map("n", "<leader>tc", close_test_terminal, opts)  -- close test pane
  end,
}
