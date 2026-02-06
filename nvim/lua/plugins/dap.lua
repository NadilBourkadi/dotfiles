-- Debug Adapter Protocol configuration
-- Python debugging with nvim-dap

return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    keys = {
      { "<leader>db", desc = "Toggle breakpoint" },
      { "<leader>dB", desc = "Conditional breakpoint" },
      { "<leader>dc", desc = "Continue" },
      { "<leader>di", desc = "Step into" },
      { "<leader>do", desc = "Step over" },
      { "<leader>dO", desc = "Step out" },
      { "<leader>dr", desc = "Open REPL" },
      { "<leader>dl", desc = "Run last" },
      { "<leader>dt", desc = "Terminate" },
      { "<leader>de", desc = "Evaluate expression" },
    },
    dependencies = {
      -- Virtual text for debugging
      {
        "theHamsta/nvim-dap-virtual-text",
        config = function()
          require("nvim-dap-virtual-text").setup({
            commented = true,
          })
        end,
      },
      -- Python adapter
      {
        "mfussenegger/nvim-dap-python",
        config = function()
          local dap = require("dap")
          local utils = require("core.utils")

          -- Helper: get Poetry venv Python path (uses shared cache)
          local function get_python_path()
            local root = vim.fs.root(0, { "pyproject.toml", ".git" }) or vim.fn.getcwd()
            local venv = utils.get_poetry_venv_cached(root)
            if venv then
              return venv .. "/bin/python"
            end
            return "python"
          end

          -- Warm the cache on plugin load
          local root = vim.fs.root(0, { "pyproject.toml", ".git" }) or vim.fn.getcwd()
          utils.get_poetry_venv(root, function() end)

          -- Configure debugpy adapter from Mason
          local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
          local debugpy_path = mason_packages .. "/debugpy/venv/bin/python"

          dap.adapters.python = {
            type = "executable",
            command = debugpy_path,
            args = { "-m", "debugpy.adapter" },
          }

          dap.configurations.python = {
            {
              type = "python",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              pythonPath = get_python_path,
            },
            {
              type = "python",
              request = "launch",
              name = "Launch file with arguments",
              program = "${file}",
              args = function()
                local args_string = vim.fn.input("Arguments: ")
                return vim.split(args_string, " +")
              end,
              pythonPath = get_python_path,
            },
            {
              type = "python",
              request = "launch",
              name = "Debug pytest test",
              module = "pytest",
              args = { "${file}", "-sv" },
              pythonPath = get_python_path,
              justMyCode = false,
            },
            {
              type = "python",
              request = "launch",
              name = "Debug pytest (stop on entry)",
              module = "pytest",
              args = { "${file}", "-sv" },
              pythonPath = get_python_path,
              stopOnEntry = true,
              justMyCode = false,
            },
            {
              type = "python",
              request = "launch",
              name = "Debug pytest test (current function)",
              module = "pytest",
              args = function()
                local function get_test_function()
                  local node = vim.treesitter.get_node()
                  while node do
                    if node:type() == "function_definition" then
                      local name_node = node:field("name")[1]
                      if name_node then
                        return vim.treesitter.get_node_text(name_node, 0)
                      end
                    end
                    node = node:parent()
                  end
                  return nil
                end
                local func = get_test_function()
                if func then
                  return { "${file}::" .. func, "-sv" }
                end
                return { "${file}", "-sv" }
              end,
              pythonPath = get_python_path,
              justMyCode = false,
            },
          }

          -- Set test runner for dap-python helper functions
          require("dap-python").setup(debugpy_path)
          require("dap-python").test_runner = "pytest"
        end,
      },
      -- UI
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dapui = require("dapui")
          dapui.setup()

          -- Auto open/close UI with debug session
          local dap = require("dap")
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.disconnect["dapui_config"] = function()
            dapui.close()
          end
        end,
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Keymaps
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map("n", "<leader>db", dap.toggle_breakpoint, opts)
      map("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, opts)
      map("n", "<leader>dc", dap.continue, opts)
      map("n", "<leader>di", dap.step_into, opts)
      map("n", "<leader>do", dap.step_over, opts)
      map("n", "<leader>dO", dap.step_out, opts)
      map("n", "<leader>dr", dap.repl.open, opts)
      map("n", "<leader>dl", dap.run_last, opts)
      map("n", "<leader>dt", dap.terminate, opts)
      map("n", "<leader>dq", function()
        dap.terminate()
        dapui.close()
        dap.clear_breakpoints()
      end, opts)
      map("n", "<leader>du", dapui.toggle, opts)
      map({ "n", "v" }, "<leader>de", dapui.eval, opts)

      -- Signs
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◐", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticInfo", linehl = "CursorLine", numhl = "" })
    end,
  },
}
