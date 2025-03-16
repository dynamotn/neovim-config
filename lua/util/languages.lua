local languages_list = require('config.languages')

local M = {}

--- Return language from filetype
---@param filetype string Filetype of buffer
M.get_language_from_filetype = function(filetype)
  for name, language in pairs(languages_list) do
    for _, ft in pairs(language.filetypes) do
      if filetype == ft and vim.list_contains(_G.enabled_languages, name) then
        return name
      end
    end
  end
end

--- Return list command of tools for formatters, linters and other actions
---@param filetype string Filetype of buffer
---@return string[]
M.get_tools_by_filetype = function(filetype)
  local result = {}
  local language_name = M.get_language_from_filetype(filetype) or '_'
  local formatters = vim.list_extend(
    vim.deepcopy(languages_list['*'].formatters or {}),
    languages_list[language_name].formatters or {}
  )
  local linters = vim.list_extend(
    vim.deepcopy(languages_list['*'].linters or {}),
    languages_list[language_name].linters or {}
  )
  local null_ls = vim.list_extend(
    vim.deepcopy(languages_list['*'].null_ls or {}),
    languages_list[language_name].null_ls or {}
  )

  for _, tool in ipairs(formatters or {}) do
    if type(tool) == 'string' then
      table.insert(result, tool)
    elseif type(formatters) == 'table' then
      table.insert(result, tool.command or tool[1])
    end
  end

  for _, tool in ipairs(linters or {}) do
    if type(tool) == 'string' then
      table.insert(result, tool)
    elseif type(linters) == 'table' then
      table.insert(result, tool.command or tool[1])
    end
  end

  for _, tool in ipairs(null_ls or {}) do
    table.insert(result, tool.command)
  end
  return LazyVim.dedup(result)
end

return M
