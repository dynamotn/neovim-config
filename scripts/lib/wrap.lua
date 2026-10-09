-- Fill a paragraph to a width, for the prose the benchmark scripts write into
-- README.md: a table row cannot be broken, but a sentence can, and the README
-- keeps to 80 columns wherever it is able to.

local M = {}

--- The lines of `text` filled to at most `width` columns, a word longer than
--- that left on a line of its own
---@param text string
---@param width? integer 80 unless given
---@return string[]
function M.wrap(text, width)
  width = width or 80
  local lines, line = {}, nil
  for word in text:gmatch('%S+') do
    if not line then
      line = word
    elseif vim.fn.strdisplaywidth(line .. ' ' .. word) <= width then
      line = line .. ' ' .. word
    else
      lines[#lines + 1] = line
      line = word
    end
  end
  lines[#lines + 1] = line
  return lines
end

--- Markdown `lines` with each line of prose filled to `width`, and table
--- rows, headings, HTML comments and fenced code left as they are
---@param lines string[]
---@param width? integer 80 unless given
---@return string[]
function M.prose(lines, width)
  local out, fenced = {}, false
  for _, line in ipairs(lines) do
    if line:match('^```') then fenced = not fenced end
    if fenced or line:match('^```') or line:match('^[|#<]') or line == '' then
      out[#out + 1] = line
    else
      vim.list_extend(out, M.wrap(line, width))
    end
  end
  return out
end

return M
