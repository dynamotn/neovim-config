local languages = require('languages.list')
local lspconfig = require('languages.lspconfig')

local M = {}

M.setup_autopairs = function(rule, cond, ts_cond)
  local result = {}
  for language, filetypes in pairs(languages) do
    local ok, autopairs = pcall(require, 'languages.' .. language .. '.autopairs')
    if ok and type(autopairs) == 'function' then
      local list = autopairs(filetypes, rule, cond, ts_cond)

      if type(list) == 'table' then
        for _, autopair in ipairs(list) do
          table.insert(result, autopair)
        end
      end
    end
  end
  return result
end

M.setup_dial = function(augend)
  local result = {}
  for language, _ in pairs(languages) do
    local ok, dial = pcall(require, 'languages.' .. language .. '.dial')
    if ok and type(dial) == 'function' then
      result[language] = dial(augend)
    end
  end
  return result
end

M.setup_ls = function()
  local result = {}
  for language, filetypes in pairs(languages) do
    local ok, server_names = pcall(require, 'languages.' .. language .. '.lsp')
    if ok and type(server_names) == 'table' then
      for _, server_name in ipairs(server_names) do
        if not result[server_name] then
          result[server_name] = {
            setup = lspconfig[server_name] or function(opts)
              return opts
            end,
            filetypes = vim.deepcopy(filetypes),
          }
        else
          vim.list_extend(result[server_name].filetypes, filetypes)
        end
      end
    end
  end
  return result
end

M.get_ls_by_filetype = function(filetype)
  local language = M.get_language_from_filetype(filetype)
  if not language then
    return {}
  end

  local ok, server_names = pcall(require, 'languages.' .. language .. '.lsp')

  local result = {}
  if ok and type(server_names) == 'table' then
    for _, server_name in ipairs(server_names) do
      table.insert(result, server_name)
    end
  end

  return result
end

M.setup_treesitter = function(parser_config)
  local result = {}

  for language, filetypes in pairs(languages) do
    local ok, treesitter = pcall(require, 'languages.' .. language .. '.treesitter')

    if ok and type(treesitter) == 'table' then
      for _, config in ipairs(treesitter) do
        if config.parser then
          table.insert(result, config.parser)

          for _, ft in pairs(filetypes) do
            vim.treesitter.language.register(config.parser, ft)
          end

          if type(config.install_info) == 'table' then
            parser_config[config.parser] = {
              filetypes = filetypes,
            }
            parser_config[config.parser].install_info = config.install_info
            if type(config.used_by) == 'table' then
              parser_config[config.parser].used_by = vim.list_extend(config.used_by, filetypes)
            end
          end
          if type(config.used_by) == 'table' then
            parser_config[config.parser]['used_by'] = vim.list_extend(filetypes, config.used_by)
          end
        end
      end
    end
  end
  return result
end

M.get_parsers_by_filetype = function(filetype)
  local language = M.get_language_from_filetype(filetype)
  if not language then
    return {}
  end

  local ok, treesitter = pcall(require, 'languages.' .. language .. '.treesitter')

  local result = {}
  if ok and type(treesitter) == 'table' then
    for _, config in ipairs(treesitter) do
      if config.parser then
        table.insert(result, config.parser)
      end
    end
  end

  return result
end

M.setup_dap = function()
  local dapconfig = require('languages.dapconfig')
  local result = {}

  for language, filetypes in pairs(languages) do
    local ok, server_names = pcall(require, 'languages.' .. language .. '.dap')

    if ok and type(server_names) == 'table' then
      for _, server_name in ipairs(server_names) do
        if not result[server_name] then
          local adapter, configurations, mason_install = {}, {}, false

          if dapconfig[server_name] then
            adapter = dapconfig[server_name].adapter or {}
            configurations = dapconfig[server_name].configurations or {}
            mason_install = dapconfig[server_name].mason_install or false
          end

          result[server_name] = {
            adapter = adapter,
            configurations = configurations,
            mason_install = mason_install,
            filetypes = vim.deepcopy(filetypes),
          }
        else
          vim.list_extend(result[server_name].filetypes, filetypes)
        end
      end
    end
  end

  return result
end

M.get_dap_by_filetype = function(filetype)
  local language = M.get_language_from_filetype(filetype)
  if not language then
    return {}
  end

  local ok, server_names = pcall(require, 'languages.' .. language .. '.dap')

  local result = {}
  if ok and type(server_names) == 'table' then
    for _, server_name in ipairs(server_names) do
      table.insert(result, server_name)
    end
  end

  return result
end

M.setup_null_ls = function()
  local list_tools = {}
  local result = {}

  for language, filetypes in pairs(languages) do
    local ok, null_ls_config = pcall(require, 'languages.' .. language .. '.null_ls')

    if ok then
      for _, source in ipairs(null_ls_config) do
        source.with_config = source.with_config or {}
        source.with_config['filetypes'] = {}
        local tool_kind = source[1] .. '_' .. source[2]

        if list_tools[tool_kind] == nil then
          source.with_config['filetypes'] = filetypes
        else
          vim.list_extend(list_tools[tool_kind].with_config['filetypes'], filetypes)
          source.with_config['filetypes'] = list_tools[tool_kind].with_config['filetypes']
        end
        list_tools[tool_kind] = source
      end
    end
  end

  local nullls_util = require('util.null_ls')
  for tool_kind, source in pairs(list_tools) do
    local tool = nullls_util.active_tool({
      name = source[1],
      method = source[2],
      is_external_tool = source.is_external_tool,
      is_custom_tool = source.is_custom_tool,
      with_config = source.with_config,
      tool = source.tool,
      is_none_ls_extra_tool = source.is_none_ls_extra_tool,
    })
    if tool then
      result[tool_kind] = tool
    end
  end

  return result
end

M.setup_conform = function()
  local result = {
    ['_'] = { 'trim_whitespace' },
  }
  for language, filetypes in pairs(languages) do
    local ok, formatters = pcall(require, 'languages.' .. language .. '.formatter')
    if ok and type(formatters) == 'table' then
      for _, filetype in ipairs(filetypes) do
        local formatters_by_ft = {}
        for _, formatter in ipairs(formatters) do
          if type(formatter) == 'table' then
            table.insert(formatters_by_ft, formatter[1])
            if formatter.with_config then
              require('conform').formatters[formatter[1]] = formatter.with_config
            end
          else
            table.insert(formatters_by_ft, formatter)
          end
        end
        result[filetype] = formatters_by_ft
      end
    end
  end
  return result
end

M.get_tools_by_filetype = function(filetype)
  local result = {
    ec = false,
    vale = true,
  }

  for language, filetypes in pairs(languages) do
    for _, ft in pairs(filetypes) do
      if ft == filetype then
        local ok, null_ls_config = pcall(require, 'languages.' .. language .. '.null_ls')

        if ok then
          for _, source in ipairs(null_ls_config) do
            if source.is_external_tool == true or source.is_external_tool == nil then
              local tool = source.tool and source.tool or source[1]
              if source.is_custom_tool then
                result[tool] = false
              else
                if source.is_mason_tool ~= nil then
                  result[tool] = source.is_mason_tool
                else
                  result[tool] = true
                end
              end
            end
          end
        end

        local ok, formatters = pcall(require, 'languages.' .. language .. '.formatter')
        if ok then
          for _, formatter in ipairs(formatters) do
            if type(formatter) == 'table' then
              local tool = formatter.tool and formatter.tool or formatter[1]
              result[tool] = true
            else
              result[formatter] = true
            end
          end
        end

        return result
      end
    end
  end
end

M.setup_test = function()
  local result = {}
  for language, _ in pairs(languages) do
    local ok, test = pcall(require, 'languages.' .. language .. '.test')

    if ok then
      table.insert(result, test)
    end
  end
  return result
end

M.get_cmp_sources = function()
  local result = {}

  for language, filetypes in pairs(languages) do
    local ok, cmp = pcall(require, 'languages.' .. language .. '.cmp')

    if ok then
      table.insert(result, {
        sources = cmp,
        filetypes = filetypes,
      })
    end
  end
  return result
end

M.get_plugins = function()
  local result = {}

  for language, filetypes in pairs(languages) do
    local ok, plugins = pcall(require, 'languages.' .. language .. '.plugins')

    if ok then
      for _, plugin in ipairs(plugins) do
        if next(plugin) ~= nil then
          plugin['ft'] = filetypes
          table.insert(result, plugin)
        end
      end
    end
  end

  return result
end

M.get_language_from_filetype = function(filetype)
  for language, filetypes in pairs(languages) do
    for _, ft in ipairs(filetypes) do
      if filetype == ft then
        return language
      end
    end
  end
end

return M
