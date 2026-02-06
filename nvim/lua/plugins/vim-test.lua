-- Test runner configuration
-- Using vim-test with custom gutter indicators (see core/test-signs.lua)

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

    -- Ensure signcolumn is visible
    vim.opt.signcolumn = "yes"

    -- Define signs for test results
    vim.fn.sign_define("TestPassed", { text = "✓", texthl = "DiagnosticOk" })
    vim.fn.sign_define("TestFailed", { text = "✗", texthl = "DiagnosticError" })
    vim.fn.sign_define("TestRunning", { text = "●", texthl = "DiagnosticWarn" })

    local ts = require("core.test-signs")
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    map("n", "<leader>tn", function() ts.run_test("TestNearest") end, opts)
    map("n", "<leader>tt", function() ts.run_test("TestFile") end, opts)
    map("n", "<leader>ts", function() ts.run_test("TestSuite") end, opts)
    map("n", "<leader>tl", function() ts.run_test("TestLast") end, opts)
    map("n", "<leader>tv", "<cmd>TestVisit<CR>", opts)
    map("n", "<leader>tc", function()
      ts.close_test_terminal()
      if ts.state.test_buf then
        ts.clear_signs(ts.state.test_buf)
      end
    end, opts)

    -- Manual refresh signs from terminal output
    map("n", "<leader>tr", function()
      ts.state.term_buf = ts.find_test_terminal()
      ts.state.test_buf = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
      if ts.state.term_buf and ts.state.test_buf then
        ts.update_signs_from_terminal()
      end
    end, opts)

    -- Auto-update signs when test terminal closes
    vim.api.nvim_create_autocmd("TermClose", {
      callback = function(args)
        if args.buf == ts.state.term_buf then
          vim.schedule(function()
            ts.on_complete(args.buf)
          end)
        end
      end,
    })
  end,
}
