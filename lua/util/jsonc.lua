--- JSON with the extensions VS Code allows in its own files
local M = {}

--- Skip whitespace and comments from `i` on
---@param str string
---@param i integer
---@return integer index of the next significant character
local function skip_blank(str, i)
  local n = #str
  while i <= n do
    if str:sub(i, i):match('%s') then
      i = i + 1
    elseif str:sub(i, i + 1) == '//' then
      i = (str:find('\n', i, true) or n) + 1
    elseif str:sub(i, i + 1) == '/*' then
      local _, stop = str:find('*/', i + 2, true)
      i = (stop or n) + 1
    else
      break
    end
  end
  return i
end

--- `str` without the commas left before a closing bracket, which JSON does
--- not allow. Strings and comments are left as they are.
---@param str string
---@return string
function M.strip_trailing_commas(str)
  local out = {}
  local i, n = 1, #str
  while i <= n do
    local c = str:sub(i, i)
    local stop
    if c == '"' then
      stop = i + 1
      while stop <= n do
        local d = str:sub(stop, stop)
        if d == '\\' then
          stop = stop + 2
        elseif d == '"' then
          break
        else
          stop = stop + 1
        end
      end
    elseif str:sub(i, i + 1) == '//' then
      stop = str:find('\n', i, true) or n
    elseif str:sub(i, i + 1) == '/*' then
      stop = select(2, str:find('*/', i + 2, true)) or n
    elseif c == ',' then
      local next_char = str:sub(skip_blank(str, i + 1)):sub(1, 1)
      if next_char == ']' or next_char == '}' then c = '' end
    end
    if stop then
      table.insert(out, str:sub(i, stop))
      i = stop + 1
    else
      table.insert(out, c)
      i = i + 1
    end
  end
  return table.concat(out)
end

--- Decode JSONC: comments and trailing commas allowed
---@param str string
---@return any
function M.decode(str)
  return vim.json.decode(M.strip_trailing_commas(str), { skip_comments = true })
end

return M
