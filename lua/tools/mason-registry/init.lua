local list_tools = {
  'jira',
  'ltcc',
  'js-beautify',
  'typos',
  'promql-langserver',
  'termux-language-server',
  'sonarlint-language-server',
  'd2',
}

local M = {}

for _, tool in ipairs(list_tools) do
  M = vim.tbl_extend('keep', M, { [tool] = 'tools.mason-registry.' .. tool })
end

return M
