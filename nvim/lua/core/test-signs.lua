-- Test gutter sign management and pytest output parsing

local M = {}

-- Track the test file buffer and terminal buffer
M.state = {
  test_file = nil,
  test_buf = nil,
  term_buf = nil,
  signs_placed = {},
}

-- Max poll iterations (60 * 500ms = 30 seconds)
local MAX_POLL_COUNT = 60

-- Clear all test signs from a buffer
function M.clear_signs(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.fn.sign_unplace("test_results", { buffer = bufnr })
  end
  M.state.signs_placed = {}
end

-- Find line numbers of test functions in a buffer
function M.find_test_functions(bufnr)
  local tests = {}
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, -1, false)
  if not ok or not lines then
    return tests
  end

  for i, line in ipairs(lines) do
    -- Match Python test functions/methods
    local test_name = line:match("def%s+(test_[%w_]+)")
    if test_name then
      tests[test_name] = i -- line number (1-indexed)
    end
  end

  return tests
end

-- Strip ANSI escape codes from a string
local function strip_ansi(str)
  return str:gsub("\027%[[%d;]*m", "")
end

-- Parse pytest output to extract test results
-- Handles both single-line results and multi-line (when -s flag shows logs between test name and result)
function M.parse_pytest_output(output_lines)
  local results = {}
  local current_test = nil

  for _, line in ipairs(output_lines) do
    -- Strip ANSI color codes first
    local clean_line = strip_ansi(line)

    -- Try single-line match: ::test_name followed eventually by PASSED/FAILED on same line
    local test_name = nil
    local status = nil

    -- Check if line contains both a test name (after ::) and a status
    if clean_line:match("::") and clean_line:match("PASSED") then
      for name in clean_line:gmatch("::([%w_]+)") do
        if name:match("^test_") then
          test_name = name
        end
      end
      if test_name then status = "PASSED" end
    elseif clean_line:match("::") and clean_line:match("FAILED") then
      for name in clean_line:gmatch("::([%w_]+)") do
        if name:match("^test_") then
          test_name = name
        end
      end
      if test_name then status = "FAILED" end
    elseif clean_line:match("::") and clean_line:match("SKIPPED") then
      for name in clean_line:gmatch("::([%w_]+)") do
        if name:match("^test_") then
          test_name = name
        end
      end
      if test_name then status = "SKIPPED" end
    elseif clean_line:match("::") and clean_line:match("ERROR") then
      for name in clean_line:gmatch("::([%w_]+)") do
        if name:match("^test_") then
          test_name = name
        end
      end
      if test_name then status = "ERROR" end
    end

    if test_name and status then
      -- Single line match (test name and status on same line)
      results[test_name] = status
      current_test = nil
    else
      -- Check if this line starts a new test (test name without result)
      -- Pattern: file.py::ClassName::test_name or file.py::test_name
      -- Handle parametrized tests like test_name[param1-param2] by matching until [ or whitespace
      local new_test = clean_line:match("%.py::.-::([%w_]+)[%s%[]") or clean_line:match("%.py::([%w_]+)[%s%[]")
      if new_test and new_test:match("^test_") then
        current_test = new_test
      end

      -- Check if this line is just a status (for multi-line output with -s flag)
      local standalone_status = clean_line:match("^(PASSED)%s*$") or clean_line:match("^(FAILED)%s*$")
                               or clean_line:match("^(SKIPPED)%s*$") or clean_line:match("^(ERROR)%s*$")
      if standalone_status and current_test then
        results[current_test] = standalone_status
        current_test = nil
      end
    end
  end

  return results
end

-- Place signs based on test results
function M.place_test_signs(bufnr, test_functions, test_results)
  M.clear_signs(bufnr)

  for test_name, line_num in pairs(test_functions) do
    local result = test_results[test_name]
    local sign_name = nil

    if result == "PASSED" then
      sign_name = "TestPassed"
    elseif result == "FAILED" or result == "ERROR" then
      sign_name = "TestFailed"
    end

    if sign_name then
      local sign_id = vim.fn.sign_place(0, "test_results", sign_name, bufnr, { lnum = line_num })
      if sign_id > 0 then
        table.insert(M.state.signs_placed, { id = sign_id, bufnr = bufnr })
      end
    end
  end
end

-- Place "running" signs on all tests before running
function M.place_running_signs(bufnr)
  M.clear_signs(bufnr)
  local test_functions = M.find_test_functions(bufnr)

  for _, line_num in pairs(test_functions) do
    local sign_id = vim.fn.sign_place(0, "test_results", "TestRunning", bufnr, { lnum = line_num })
    table.insert(M.state.signs_placed, { id = sign_id, bufnr = bufnr })
  end
end

-- Get terminal buffer content
local function get_terminal_output(term_buf)
  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    return {}
  end
  return vim.api.nvim_buf_get_lines(term_buf, 0, -1, false)
end

-- Update signs after tests complete
function M.update_signs_from_terminal()
  if not M.state.test_buf or not vim.api.nvim_buf_is_valid(M.state.test_buf) then
    return
  end
  if not M.state.term_buf or not vim.api.nvim_buf_is_valid(M.state.term_buf) then
    return
  end

  local output_lines = get_terminal_output(M.state.term_buf)
  local test_results = M.parse_pytest_output(output_lines)
  local test_functions = M.find_test_functions(M.state.test_buf)

  M.place_test_signs(M.state.test_buf, test_functions, test_results)
end

-- Find the test terminal buffer
function M.find_test_terminal()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("test") or name:match("pytest") then
        return buf
      end
    end
  end
  return nil
end

-- Close existing test terminal before running new test
function M.close_test_terminal()
  -- First close windows, then delete buffers
  local bufs_to_delete = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("test") or name:match("jest") or name:match("pytest") or name:match("go test") or name:match("cargo test") then
        vim.api.nvim_win_close(win, true)
        table.insert(bufs_to_delete, buf)
      end
    end
  end
  -- Also find any hidden terminal buffers from previous test runs
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("test") or name:match("jest") or name:match("pytest") or name:match("go test") or name:match("cargo test") then
        table.insert(bufs_to_delete, buf)
      end
    end
  end
  -- Delete the buffers
  for _, buf in ipairs(bufs_to_delete) do
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
  -- Clear state
  M.state.term_buf = nil
end

-- Check if pytest output indicates completion
function M.is_pytest_complete(lines)
  for _, line in ipairs(lines) do
    -- Pytest summary lines indicate completion
    if line:match("=%s*%d+%s+passed") or
       line:match("=%s*%d+%s+failed") or
       line:match("=%s*%d+%s+error") or
       line:match("passed in %d") or
       line:match("failed in %d") or
       line:match("error in %d") then
      return true
    end
  end
  return false
end

-- Poll terminal for test completion (with timeout)
function M.poll_for_completion(poll_count)
  poll_count = poll_count or 0

  if not M.state.term_buf or not vim.api.nvim_buf_is_valid(M.state.term_buf) then
    return
  end

  if poll_count >= MAX_POLL_COUNT then
    return
  end

  local output_lines = get_terminal_output(M.state.term_buf)
  if M.is_pytest_complete(output_lines) then
    M.update_signs_from_terminal()
  else
    -- Keep polling every 500ms
    vim.defer_fn(function()
      M.poll_for_completion(poll_count + 1)
    end, 500)
  end
end

-- Run test with gutter indicator support
function M.run_test(cmd)
  -- Store current test file - get buffer from current window
  local current_buf = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
  local current_file = vim.api.nvim_buf_get_name(current_buf)
  if current_file:match("test_") or current_file:match("_test%.py$") then
    M.state.test_file = current_file
    M.state.test_buf = current_buf
    -- Show running indicators
    M.place_running_signs(M.state.test_buf)
  end

  M.close_test_terminal()
  vim.cmd(cmd)

  -- Find terminal buffer and start polling for completion
  vim.defer_fn(function()
    M.state.term_buf = M.find_test_terminal()
    if M.state.term_buf then
      -- Start polling for test completion
      vim.defer_fn(function()
        M.poll_for_completion(0)
      end, 1000)
    end
  end, 300)
end

return M
