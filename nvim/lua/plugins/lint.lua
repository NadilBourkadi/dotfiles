-- Linting configuration
-- mypy + flake8 for Python (uses Poetry venv versions for project config)

return {
  "mfussenegger/nvim-lint",
  event = { "BufWritePost", "BufReadPost" },
  config = function()
    local lint = require("lint")
    local utils = require("core.utils")

    -- Helper: find project root with pyproject.toml
    local function find_project_root()
      local root = vim.fs.root(0, { "pyproject.toml", ".git" })
      return root or vim.fn.getcwd()
    end

    -- Configure mypy to run from project root with Poetry's mypy
    lint.linters.mypy = {
      cmd = function()
        local root = find_project_root()
        local venv = utils.get_poetry_venv_cached(root)
        if venv and vim.fn.executable(venv .. "/bin/mypy") == 1 then
          return venv .. "/bin/mypy"
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
        local venv = utils.get_poetry_venv_cached(root)
        if venv and vim.fn.executable(venv .. "/bin/flake8") == 1 then
          return venv .. "/bin/flake8"
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
    -- Resolves Poetry venv path async on first call, then lints
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      pattern = { "*.py" },
      callback = function()
        local root = find_project_root()
        if utils.is_poetry_venv_resolved(root) then
          lint.try_lint()
        else
          utils.get_poetry_venv(root, function()
            lint.try_lint()
          end)
        end
      end,
    })
  end,
}
