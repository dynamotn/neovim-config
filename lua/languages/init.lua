local languages = {
    lua = { 'lua' },
    javascript = {
        'javascript',
        'typescript',
        'javascriptreact',
        'typescriptreact',
    },
    bash = {
        'sh',
        'bats',
    },
    terraform = {
        'terraform',
        'hcl',
    },
}

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

M.setup_null_ls = function(null_ls)
    local result = {}

    for language, filetypes in pairs(languages) do
        local ok, null_ls_config = pcall(require, 'languages.' .. language .. '.null_ls')

        if ok then
            for _, sources in ipairs(null_ls_config.sources(null_ls, filetypes)) do
                table.insert(result, sources)
            end
        end
    end

    return result
end

M.get_tools_by_filetype = function(filetype)
    for language, filetypes in pairs(languages) do
        for _, ft in pairs(filetypes) do
            if ft == filetype then
                local ok, null_ls_config = pcall(require, 'languages.' .. language .. '.null_ls')

                if not ok then
                    return
                end

                return null_ls_config.tools
            end
        end
    end
end

return M
