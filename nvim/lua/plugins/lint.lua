-- Linting configuration
-- mypy + flake8 for Python (uses Poetry venv versions for project config)

return {
  "mfussenegger/nvim-lint",
  event = { "BufWritePost", "BufReadPost" },
  config = function()
    local lint = require("lint")

    -- Cache: project root -> poetry bin path (false = no poetry)
    local poetry_cache = {}

    -- Helper: find project root with pyproject.toml
    local function find_project_root()
      local root = vim.fs.root(0, { "pyproject.toml", ".git" })
      return root or vim.fn.getcwd()
    end

    -- Async resolve Poetry venv bin path, then call callback
    local function resolve_poetry_bin(root, callback)
      -- Cache hit
      if poetry_cache[root] ~= nil then
        callback(poetry_cache[root] ~= false and poetry_cache[root] or nil)
        return
      end
      -- Async lookup
      vim.system(
        { "poetry", "env", "info", "--path" },
        { cwd = root, text = true },
        function(result)
          vim.schedule(function()
            if result.code == 0 and result.stdout and result.stdout ~= "" then
              poetry_cache[root] = vim.trim(result.stdout) .. "/bin"
            else
              poetry_cache[root] = false
            end
            callback(poetry_cache[root] ~= false and poetry_cache[root] or nil)
          end)
        end
      )
    end

    -- Sync read from cache (used by linter cmd functions after cache is warm)
    local function get_poetry_bin_cached(root)
      local cached = poetry_cache[root]
      if cached and cached ~= false then
        return cached
      end
      return nil
    end

    -- Configure mypy to run from project root with Poetry's mypy
    lint.linters.mypy = {
      cmd = function()
        local root = find_project_root()
        local poetry_bin = get_poetry_bin_cached(root)
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
        local poetry_bin = get_poetry_bin_cached(root)
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
    -- Resolves Poetry venv path async on first call, then lints
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      pattern = { "*.py" },
      callback = function()
        local root = find_project_root()
        if poetry_cache[root] ~= nil then
          lint.try_lint()
        else
          resolve_poetry_bin(root, function()
            lint.try_lint()
          end)
        end
      end,
    })
  end,
}
