local languages = require('languages.list')

local M = {}

M.setup_autopairs = function(rule, cond)
    local result = {}
    for language, filetypes in pairs(languages) do
        local ok, autopairs = pcall(require, 'languages.' .. language .. '.autopairs')
        if ok and type(autopairs) == 'function' then
            local list = autopairs(filetypes, rule, cond)

            if type(list) == 'table' then
                for _, autopair in ipairs(list) do
                    table.insert(result, autopair)
                end
            end
        end
    end
    return result
end

M.setup_ls = function()
    local result = {}
    for language, filetypes in pairs(languages) do
        local ok, lsp = pcall(require, 'languages.' .. language .. '.lsp')
        if ok and type(lsp) == 'table' then
            result[lsp.ls] = {
                config = lsp.config or function() end,
                filetypes = filetypes,
            }
        end
    end
    return result
end

M.setup_treesitter = function(parser_config)
    local parsers, gps_configs = {}, {}

    for language, filetypes in pairs(languages) do
        local ok, treesitter = pcall(require, 'languages.' .. language .. '.treesitter')
        local parser, gps_config

        if not ok or type(treesitter) ~= 'table' then
            parser = language
        else
            parser = treesitter.parser
            gps_config = treesitter.gps_config or {}
        end

        table.insert(parsers, parser)
        table.insert(gps_configs, gps_config)

        for _, ft in pairs(filetypes) do
            parser_config[ft] = parser
        end
    end
    return parsers, gps_configs
end

M.setup_null_ls = function()
    local result = {}

    for language, filetypes in pairs(languages) do
        local ok, null_ls_config = pcall(require, 'languages.' .. language .. '.null_ls')

        if ok then
            for _, source in ipairs(null_ls_config) do
                if #source >= 2 then
                    source.with_config = source.with_config or {}
                    table.insert(source.with_config, { filetypes = filetypes })

                    local tool = dynamo_nullls_tool(
                        source[1],
                        source[2],
                        source.is_external_tool,
                        source.is_custom_tool,
                        source.with_config
                    )
                    if tool then
                        table.insert(result, tool)
                    end
                end
            end
        end
    end

    return result
end

M.get_tools_by_filetype = function(filetype)
    local result = {}

    for language, filetypes in pairs(languages) do
        for _, ft in pairs(filetypes) do
            if ft == filetype then
                local ok, null_ls_config = pcall(require, 'languages.' .. language .. '.null_ls')

                if not ok then
                    return
                end

                for _, source in ipairs(null_ls_config) do
                    if source.is_external_tool == true or source.is_external_tool == nil then
                        result[source[1]] = true
                    end
                end

                return result
            end
        end
    end
end

M.get_plugins = function()
    local result = {}
    local register_config = require('plugins.register').register_config

    for language, filetypes in pairs(languages) do
        local ok, plugins = pcall(require, 'languages.' .. language .. '.plugins')

        if ok then
            for _, plugin in ipairs(plugins(register_config)) do
                plugin['ft'] = filetypes
                table.insert(result, plugin)
            end
        end
    end

    return result
end

return M
