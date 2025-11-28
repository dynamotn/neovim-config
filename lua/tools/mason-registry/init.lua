local M = {}
local scan_path = vim.fn.stdpath('config') .. '/lua/tools/mason-registry'
local files = vim.fn.glob(scan_path .. '/*.lua', true, true)

for _, file in ipairs(files) do
  local tool_name = vim.fn.fnamemodify(file, ':t:r')
  if tool_name ~= 'init' then
    M = vim.tbl_extend('keep', M, {
      [tool_name] = 'tools.mason-registry.' .. tool_name,
    })
  end
end

return M
