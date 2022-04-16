return function(whichkey, bufnr)
    whichkey.register({
        ['gd'] = { '<cmd>Lspsaga preview_definition<CR>', 'Preview definition' },
        ['gh'] = { '<cmd>Lspsaga lsp_finder<CR>', 'Show definition and references' },
        ['K'] = { '<cmd>Lspsaga hover_doc<CR>', 'Hover document' },
        ['<C-u>'] = {
            "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>",
            'Scroll up in preview window',
        },
        ['<C-d>'] = {
            "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>",
            'Scroll down in preview window',
        },
        ['<C-k>'] = { '<cmd>Lspsaga signature_help<CR>', 'Signature help' },
        ['<Space>lr'] = { '<cmd>Lspsaga rename<CR>', 'Rename' },
        ['<Space>la'] = { '<cmd>Lspsaga code_action<CR>', 'Code Action' },
    }, { buffer = bufnr })

    whichkey.register({
        ['<Space>la'] = { '<cmd><C-u>Lspsaga range_code_action<CR>', 'Code Action' },
    }, { buffer = bufnr, mode = 'v' })
end
