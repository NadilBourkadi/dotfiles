-- GitHub line opener (no external dependencies)

-- Get the default branch (main or master)
local function get_default_branch()
  local ref = vim.fn.systemlist("git symbolic-ref refs/remotes/origin/HEAD")[1]
  if vim.v.shell_error == 0 and ref then
    return ref:match("refs/remotes/origin/(.+)$")
  end
  -- Fallback to master if we can't detect
  return "master"
end

-- Build GitHub URL and open in browser
local function open_github_url(mode, ref)
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end

  -- Get remote URL and extract owner/repo
  local remote_url = vim.fn.systemlist("git remote get-url origin")[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("No origin remote found", vim.log.levels.ERROR)
    return
  end

  -- Parse GitHub URL (handles both SSH and HTTPS)
  local repo = remote_url:match("github%.com[:/](.+)$")
  if not repo then
    vim.notify("Not a GitHub repository", vim.log.levels.ERROR)
    return
  end
  repo = repo:gsub("%.git$", "")

  -- Get file path relative to git root
  local file_path = vim.fn.expand("%:p")
  local rel_path = file_path:sub(#git_root + 2) -- +2 for the trailing slash

  -- Get line numbers
  local lstart, lend
  if mode == "v" then
    lstart = vim.fn.line("'<")
    lend = vim.fn.line("'>")
  else
    lstart = vim.fn.line(".")
    lend = lstart
  end

  -- Build URL
  local url = string.format("https://github.com/%s/blob/%s/%s#L%d", repo, ref, rel_path, lstart)
  if lend ~= lstart then
    url = url .. "-L" .. lend
  end

  -- Open in browser
  vim.ui.open(url)
end

-- Helper to generate {n, v} keymap pairs for GitHub open commands
local function github_keys(key, ref_fn, desc)
  return {
    { key, function() open_github_url("n", ref_fn()) end, mode = "n", desc = desc },
    { key, function() open_github_url("v", ref_fn()) end, mode = "v", desc = desc:gsub("line", "selection") },
  }
end

local function get_head_rev()
  local rev = vim.fn.systemlist("git rev-parse HEAD")[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to get current commit", vim.log.levels.ERROR)
    return nil
  end
  return rev
end

-- Build flattened keys table
local keys = {}
vim.list_extend(keys, github_keys("<leader>go", get_default_branch, "Open line on GitHub (default branch)"))
vim.list_extend(keys, github_keys("<leader>gO", get_head_rev, "Open line on GitHub (current commit)"))

return {
  -- Virtual plugin entry for lazy.nvim keymaps (no actual plugin needed)
  dir = vim.fn.stdpath("config") .. "/lua/plugins",
  name = "open-on-github",
  keys = keys,
}
