-- Terminal-safe icon glyphs.
--
-- Alacritty gives any codepoint in the Plane-15 private use area (U+F0000+)
-- two terminal cells while Neovim and tmux both count one. Nerd Fonts put the
-- whole nf-md-* set there, which is ~1050 of mini.icons' 1200 glyphs and every
-- render-markdown heading icon, so each one silently pushes the rest of its
-- line a column right: table borders stop lining up with their header, and the
-- heading sign overflows the two-cell sign column and shifts the entire line.
--
-- There is no standard to appeal to here. UAX #11 calls U+F0000+ *Ambiguous*,
-- exactly like the basic-plane PUA that Alacritty draws in one cell, so the
-- two-cell treatment is Alacritty's own choice. It was established by
-- measurement -- a CSI 6n probe, see the tmux status-line fix -- and that
-- measurement, not the standard, is what this module encodes.
--
-- Neovim cannot be told to agree. `ambiwidth=double` looks like the matching
-- lever precisely because the range is Ambiguous, but it applies to *every*
-- ambiguous codepoint, so box drawing, bullets and em dashes go to two cells
-- too while Alacritty still draws them in one -- worse than the original bug.
-- `setcellwidths()` is surgical enough, but it would make Neovim agree with
-- Alacritty and disagree with tmux, which is Neovim's actual terminal. The
-- only cure is to not emit those codepoints. See README.md, "Icons must stay
-- out of the Plane-15 private use area".
--
-- Glyphs are written as \u{...} escapes throughout: the codepoint is the thing
-- being constrained, so it should be the thing you read, and an escape cannot
-- be mangled by a tool that mishandles private-use bytes.

local M = {}

--- Highest codepoint Alacritty, Neovim and tmux all agree is one cell wide.
M.MAX_CODEPOINT = 0xFFFF

--- True if `s` holds a codepoint above the basic multilingual plane. Those are
--- exactly the four-byte UTF-8 sequences, whose lead byte is 0xF0-0xF4, so
--- this is a byte scan rather than a decode.
---@param s any
---@return boolean
function M.is_wide(s)
  return type(s) == "string" and s:find("[\240-\244]") ~= nil
end

--- Replace every out-of-plane codepoint in `s` with `fallback`. Trailing text
--- is preserved: render-markdown's callouts are "<icon> Note", not bare icons.
---@param s string
---@param fallback string
---@return string
function M.demote_string(s, fallback)
  if not M.is_wide(s) then
    return s
  end
  local chars = {}
  for i = 1, vim.fn.strchars(s) do
    local c = vim.fn.strgetchar(s, i - 1)
    chars[#chars + 1] = c > M.MAX_CODEPOINT and fallback or vim.fn.nr2char(c)
  end
  return table.concat(chars)
end

--- Deep copy of `tbl` with every out-of-plane glyph replaced by `fallback`.
--- Used to sweep a plugin's default config, so glyphs upstream adds later are
--- caught without this repo tracking them.
---@param tbl table
---@param fallback string
---@return table copy
---@return integer substitutions
function M.demoted(tbl, fallback)
  local n = 0
  local seen = {}
  local function walk(t)
    if seen[t] then
      return seen[t]
    end
    local copy = {}
    seen[t] = copy
    for k, v in pairs(t) do
      if type(v) == "table" then
        copy[k] = walk(v)
      elseif M.is_wide(v) then
        copy[k] = M.demote_string(v, fallback)
        n = n + 1
      else
        copy[k] = v
      end
    end
    return copy
  end
  -- Sequenced, not `return walk(tbl), n`: Lua leaves the evaluation order of a
  -- return list unspecified, and `n` is an upvalue `walk` mutates.
  local copy = walk(tbl)
  return copy, n
end

--- Sweep only the top-level sections of `tbl` that actually hold an
--- out-of-plane glyph, so a caller can hand a plugin the sections it must
--- override and leave every other default live rather than pinning a copy of
--- it. Returns the partial table and the number of substitutions.
---@param tbl table
---@param fallback string
---@return table sections
---@return integer substitutions
function M.demoted_sections(tbl, fallback)
  local sections, total = {}, 0
  for key, value in pairs(tbl) do
    if type(value) == "table" then
      local swept, n = M.demoted(value, fallback)
      if n > 0 then
        sections[key] = swept
        total = total + n
      end
    elseif M.is_wide(value) then
      -- A glyph sitting directly at the top level rather than inside a
      -- section. Not the shape any plugin uses today, but sweeping defaults
      -- exists to catch what upstream adds later, so it must not fall through.
      sections[key] = M.demote_string(value, fallback)
      total = total + 1
    end
  end
  return sections, total
end

return M
