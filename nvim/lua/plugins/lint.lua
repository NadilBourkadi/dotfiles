-- Linting configuration
-- mypy + flake8 for Python (uses Poetry venv versions for project config)

return {
  "mfussenegger/nvim-lint",
  event = { "BufWritePost" },
  config = function()
    local lint = require("lint")

    -- Helper: find project root with pyproject.toml
    local function find_project_root()
      local root = vim.fs.root(0, { "pyproject.toml", ".git" })
      return root or vim.fn.getcwd()
    end

    -- Helper: get Poetry venv bin path
    local function get_poetry_bin(root)
      local result = vim.fn.system("cd " .. vim.fn.shellescape(root) .. " && poetry env info --path 2>/dev/null")
      if vim.v.shell_error == 0 and result and result ~= "" then
        return vim.trim(result) .. "/bin"
      end
      return nil
    end

    -- Configure mypy to run from project root with Poetry's mypy
    lint.linters.mypy = {
      cmd = function()
        local root = find_project_root()
        local poetry_bin = get_poetry_bin(root)
        if poetry_bin and vim.fn.executable(poetry_bin .. "/mypy") == 1 then
          return poetry_bin .. "/mypy"
        end
        return "mypy"
      end,
      stdin = false,
      args = {
        "--show-column-numbers",
        "--show-error-end",
        "--hide-error-context",
        "--no-color-output",
        "--no-error-summary",
        "--no-pretty",
      },
      stream = "stdout",
      ignore_exitcode = true,
      parser = require("lint.parser").from_pattern(
        "([^:]+):(%d+):(%d+):(%d+):(%d+): (%a+): (.+)",
        { "file", "lnum", "col", "end_lnum", "end_col", "severity", "message" },
        {
          error = vim.diagnostic.severity.ERROR,
          warning = vim.diagnostic.severity.WARN,
          note = vim.diagnostic.severity.INFO,
        }
      ),
    }

    -- Configure flake8 to use Poetry's version (has flake8-pyproject plugin)
    lint.linters.flake8 = {
      cmd = function()
        local root = find_project_root()
        local poetry_bin = get_poetry_bin(root)
        if poetry_bin and vim.fn.executable(poetry_bin .. "/flake8") == 1 then
          return poetry_bin .. "/flake8"
        end
        return "flake8"
      end,
      stdin = true,
      args = {
        "--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s",
        "--no-show-source",
        "-",
      },
      stream = "stdout",
      ignore_exitcode = true,
      parser = require("lint.parser").from_pattern(
        "([^:]+):(%d+):(%d+):(%w+):(.+)",
        { "file", "lnum", "col", "code", "message" },
        nil,
        { severity = vim.diagnostic.severity.WARN, source = "flake8" }
      ),
    }

    lint.linters_by_ft = {
      python = { "mypy", "flake8" },
    }

    -- Auto-lint on open and save for Python files
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      pattern = { "*.py" },
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
