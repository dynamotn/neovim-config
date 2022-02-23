_G.MUtils= {}

MUtils.CR = function()
    local autopairs = require('nvim-autopairs')
    if vim.fn.pumvisible() ~= 0 then
        if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
            return autopairs.esc('<C-y>')
        else
            return autopairs.esc('<C-e>') .. autopairs.autopairs_cr()
        end
    else
        return autopairs.autopairs_cr()
    end
end

MUtils.BS = function()
    local autopairs = require('nvim-autopairs')
    if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
        return autopairs.esc('<C-e>') .. autopairs.autopairs_bs()
    else
        return autopairs.autopairs_bs()
    end
end
