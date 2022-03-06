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
            gps_config = treesitter.gps_config
        end

        table.insert(parsers, parser)
        table.insert(gps_configs, gps_config)

        for _, ft in pairs(filetypes) do
            parser_config[ft] = parser
        end
    end
    return parsers, gps_configs
end

return M
