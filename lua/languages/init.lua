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
    local result = {}

    for language, filetypes in pairs(languages) do
        local ok, parser = pcall(require, 'languages.' .. language .. '.treesitter')
        if not ok or type(parser) ~= 'string' then
            parser = language
        end

        for _, ft in pairs(filetypes) do
            parser_config[ft] = parser
        end

        table.insert(result, parser)
    end
    return result
end

return M
