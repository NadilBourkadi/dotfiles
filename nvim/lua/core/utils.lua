-- Shared utility functions

local M = {}

--- Get the session state file path for the current working directory
--- Used by persistence.lua and keymaps.lua for nvim-tree state
---@param cwd? string Working directory (defaults to current)
---@return string path Full path to the state file
function M.get_state_file(cwd)
  cwd = cwd or vim.fn.getcwd()
  local name = cwd:gsub("/", "%%")
  return vim.fn.stdpath("state") .. "/sessions/" .. name .. ".state"
end

--- Save nvim-tree open/closed state to file
---@param state_file string Path to state file
---@return boolean was_open Whether nvim-tree was open
function M.save_nvim_tree_state(state_file)
  local ok, api = pcall(require, "nvim-tree.api")
  if not ok then
    return false
  end
  local was_open = api.tree.is_visible()
  vim.fn.writefile({ was_open and "1" or "0" }, state_file)
  if was_open then
    api.tree.close()
  end
  return was_open
end

--- Restore nvim-tree state from file
---@param state_file string Path to state file
function M.restore_nvim_tree_state(state_file)
  if vim.fn.filereadable(state_file) ~= 1 then
    return
  end
  local lines = vim.fn.readfile(state_file)
  if lines[1] == "1" then
    local ok, api = pcall(require, "nvim-tree.api")
    if ok then
      api.tree.open()
    end
  end
end

--- Find project root using common markers
---@param bufnr? number Buffer number (defaults to current)
---@return string root Project root directory
function M.find_project_root(bufnr)
  return vim.fs.root(bufnr or 0, {
    "pyproject.toml", "setup.py", "setup.cfg",
    "requirements.txt", ".python-version", ".git",
  }) or vim.fn.getcwd()
end

-- Cache: project root -> { path = string|false, time = number }
local poetry_venv_cache = {}
local CACHE_TTL = 300 -- 5 minutes

--- Async detect Poetry venv for a project, then call callback(venv_path_or_nil)
--- Results are cached per project root with a 5-minute TTL.
---@param root_dir string Project root directory
---@param callback fun(venv_path: string|nil)
function M.get_poetry_venv(root_dir, callback)
  -- Cache hit (within TTL)
  local entry = poetry_venv_cache[root_dir]
  if entry ~= nil and (os.time() - entry.time) < CACHE_TTL then
    callback(entry.path ~= false and entry.path or nil)
    return
  end

  local pyproject = root_dir .. "/pyproject.toml"
  if vim.fn.filereadable(pyproject) == 0 then
    poetry_venv_cache[root_dir] = { path = false, time = os.time() }
    callback(nil)
    return
  end

  local content = table.concat(vim.fn.readfile(pyproject), "\n")
  if not content:match("%[tool%.poetry%]") then
    poetry_venv_cache[root_dir] = { path = false, time = os.time() }
    callback(nil)
    return
  end

  -- Async lookup
  vim.system(
    { "poetry", "env", "info", "--path" },
    { cwd = root_dir, text = true },
    function(result)
      vim.schedule(function()
        if result.code == 0 and result.stdout and result.stdout ~= "" then
          local venv_path = vim.trim(result.stdout)
          poetry_venv_cache[root_dir] = { path = venv_path, time = os.time() }
          callback(venv_path)
        else
          poetry_venv_cache[root_dir] = { path = false, time = os.time() }
          callback(nil)
        end
      end)
    end
  )
end

--- Check if Poetry venv has been resolved (cached) for a project root
---@param root_dir string Project root directory
---@return boolean
function M.is_poetry_venv_resolved(root_dir)
  local entry = poetry_venv_cache[root_dir]
  return entry ~= nil and (os.time() - entry.time) < CACHE_TTL
end

--- Get cached Poetry venv path (sync, returns nil if not yet cached or no poetry)
---@param root_dir string Project root directory
---@return string|nil venv_path
function M.get_poetry_venv_cached(root_dir)
  local entry = poetry_venv_cache[root_dir]
  if entry and entry.path ~= false and (os.time() - entry.time) < CACHE_TTL then
    return entry.path
  end
  return nil
end

return M
