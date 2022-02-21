local present, whichkey = pcall(require, 'which-key')

if not present then
    return
end

whichkey.setup({
    key_labels = {
        ['<space>'] = '<Space>',
        ['<cr>'] = '<⏎>',
        ['<tab>'] = '<Tab>',
        ['<leader>'] = '<Leader>',
    },
    icons = {
        breadcrumn = '»',
        separator = '→',
        group = '⍟ ',
    },
    window = {
        border = 'single',
    },
    layout = {
        align = 'center',
    }
})
