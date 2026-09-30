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

--- Return the Mason package name of a tool spec
---
--- A tool's Mason package, the executable it runs and the name it carries
--- inside `conform`/`nvim-lint` are three different things. An explicit
--- `mason.package` is the only one that is always the package, so it wins;
--- `command` comes next, for the tools that expose several entries out of one
--- binary (`ruff_fix`, `ruff_format`, ...).
---@param tool string|table Tool spec from `config.languages`
---@return string
M.get_mason_package = function(tool)
  if type(tool) == 'string' then return tool end
  return (tool.mason and tool.mason.package) or tool.command or tool[1]
end

--- Return list of LSP servers for filetype
---
--- A server whose spec carries an `enabled` check is left out of a buffer it
--- turns down, the same way `plugins.lsp.server` keeps it from attaching.
---@param filetype string Filetype of buffer
---@param bufnr? integer Buffer the check is asked about, current by default
---@return string[]
M.get_lsp_servers_by_filetype = function(filetype, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local result = {}
  local language_name = M.get_language_from_filetype(filetype) or '_'
  local lsp_servers = vim.list_extend(
    vim.deepcopy(languages_list['*'].lsp_servers or {}),
    languages_list[language_name].lsp_servers or {}
  )

  for _, server in ipairs(lsp_servers) do
    local server_name = server --[[@as string]]
    if type(server) == 'table' then
      if server.enabled and not server.enabled(bufnr) then goto continue end
      server_name = server[1]
    end
    local lsp_config = vim.lsp.config[server_name]
    if lsp_config == nil or lsp_config.filetypes == nil then goto continue end
    if
      lsp_config.filetypes == '*'
      or vim.list_contains(lsp_config.filetypes, filetype)
    then
      table.insert(result, server_name)
    end
    ::continue::
  end

  return LazyVim.dedup(result)
end

return M
