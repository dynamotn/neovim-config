local languages = {
    lua = 'lua',
    javascript = {
        'javascript',
        'typescript',
        'javascriptreact',
        'typescriptreact',
    },
}

local M = {}

local filetype_by_language = function(language)
    if type(languages[language]) == 'string' then
        return { languages[language] }
    elseif type(languages[language]) == 'table' then
        return languages[language]
    end
end

M.setup_autopairs = function(rule, cond)
    local result = {}
    for language, _ in pairs(languages) do
        local ok, autopairs = pcall(require, 'languages.' .. language .. '.autopairs')
        if ok and type(autopairs) == 'function' then
            local list = autopairs(filetype_by_language(language), rule, cond)

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
    for language, _ in pairs(languages) do
        local ok, lsp = pcall(require, 'languages.' .. language .. '.lsp')
        if ok and type(lsp) == 'table' then
            result[lsp.ls] = lsp.config
        end
    end
    return result
end

M.setup_treesitter = function()
    local result = {}
    for language, _ in pairs(languages) do
        local ok, treesitter = pcall(require, 'languages.' .. language .. '.treesitter')
        if not ok or type(treesitter) ~= 'string' then
            treesitter = language
        end
        table.insert(result, treesitter)
    end
    return result
end

return M
