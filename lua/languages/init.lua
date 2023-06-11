local languages = require('languages.list')
local lspconfig = require('languages.lspconfig')

local M = {}

M.setup_autopairs = function(rule, cond, ts_cond)
  local result = {}
  for language, filetypes in pairs(languages) do
    local ok, autopairs =
      pcall(require, 'languages.' .. language .. '.autopairs')
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
    local ok, treesitter =
      pcall(require, 'languages.' .. language .. '.treesitter')

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
              parser_config[config.parser].used_by =
                vim.list_extend(config.used_by, filetypes)
            end
          end
          if type(config.used_by) == 'table' then
            parser_config[config.parser]['used_by'] =
              vim.list_extend(filetypes, config.used_by)
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

  local ok, treesitter =
    pcall(require, 'languages.' .. language .. '.treesitter')

  local result = {}
  if ok and type(treesitter) == 'table' then
    for index, config in ipairs(treesitter) do
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
  local result = {}

  for language, filetypes in pairs(languages) do
    local ok, null_ls_config =
      pcall(require, 'languages.' .. language .. '.null_ls')

    if ok then
      for _, source in ipairs(null_ls_config) do
        if #source >= 2 then
          source.with_config = source.with_config or {}
          source.with_config['filetypes'] = filetypes

          local tool = dynamo_nullls_tool(
            source[1],
            source[2],
            source.is_external_tool,
            source.is_custom_tool,
            source.with_config
          )
          if tool then
            result[source[1]] = tool
          end
        end
      end
    end
  end

  return result
end

M.get_tools_by_filetype = function(filetype)
  local result = {
    ['editorconfig-checker'] = true,
    vale = true,
  }

  for language, filetypes in pairs(languages) do
    for _, ft in pairs(filetypes) do
      if ft == filetype then
        local ok, null_ls_config =
          pcall(require, 'languages.' .. language .. '.null_ls')

        if not ok then
          return {}
        end

        for _, source in ipairs(null_ls_config) do
          if
            source.is_external_tool == true or source.is_external_tool == nil
          then
            local tool = source.tool and source.tool or source[1]

            result[tool] = true
          end
        end

        return result
      end
    end
  end
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
