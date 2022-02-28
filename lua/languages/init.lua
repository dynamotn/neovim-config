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

return M
