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

--- Return list of Treesitter parsers by filetype
---@param filetype string Filetype of buffer
---@return table List of parsers
M.get_parsers_by_filetype = function(filetype)
  local language = M.get_language_from_filetype(filetype)
  local result = {}
  if not language then
    return result
  end
  for _, parser in ipairs(languages_list[language].parsers) do
    if type(parser) == 'string' then
      table.insert(result, parser)
    elseif type(parser) == 'table' then
      table.insert(result, parser[1])
    end
  end

  return result
end

--- Return list command of tools for formatters, linters and other actions
---@param filetype string Filetype of buffer
---@return string[]
M.get_tools_by_filetype = function(filetype)
  local result = {}
  local language_name = M.get_language_from_filetype(filetype)
  local formatters = languages_list[language_name].formatters
  local linters = languages_list[language_name].linters
  local null_ls = languages_list[language_name].null_ls

  if formatters then
    for _, tool in ipairs(formatters) do
      if type(tool) == 'string' then
        table.insert(result, tool)
      elseif type(formatters) == 'table' then
        table.insert(result, tool.command and tool.command or tool[1])
      end
    end
  end

  if linters then
    for _, tool in ipairs(linters) do
      if type(tool) == 'string' then
        table.insert(result, tool)
      elseif type(linters) == 'table' then
        table.insert(result, tool[1])
      end
    end
  end

  if null_ls then
    for _, tool in ipairs(null_ls) do
      table.insert(result, tool.command)
    end
  end
  return LazyVim.dedup(result)
end

--- Check a LSP server of a language is in bundle languages or not
---@param lsp_name string LSP server name (follow by lspconfig)
---@return boolean
M.check_lsp_is_for_bundled_language = function(lsp_name)
  for name, language in pairs(languages_list) do
    if language.lsp_servers then
      for _, server in ipairs(language.lsp_servers) do
        local server_name = ''
        if type(server) == 'string' then
          server_name = server
        elseif type(server) == 'table' then
          server_name = server[1]
        end
        if server_name == lsp_name and vim.list_contains(_G.bundle_languages, name) then
          return true
        end
      end
    end
  end
  return false
end

return M
