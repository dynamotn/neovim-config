return function(whichkey, bufnr)
    whichkey.register({
        ['gD'] = { '<cmd>lua vim.lsp.buf.declaration()<CR>', 'Go to declaration' },
        ['gd'] = { '<cmd>lua vim.lsp.buf.definition()<CR>', 'Go to definition' },
        ['gi'] = { '<cmd>lua vim.lsp.buf.implementation()<CR>', 'Go to implementation' },
        ['gt'] = { '<cmd>lua vim.lsp.buf.type_definition()<CR>', 'Go to type definition' },
        ['gr'] = { '<cmd>lua vim.lsp.buf.references()<CR>', 'Go to references' },
        ['K'] = { '<cmd>lua vim.lsp.buf.hover()<CR>', 'Hover' },
        ['<C-k>'] = { '<cmd>lua vim.lsp.buf.signature_help()<CR>', 'Signature help' },
        ['<Space>lr'] = { '<cmd>lua vim.lsp.buf.rename()<CR>', 'Rename' },
        ['<Space>la'] = { '<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Action' },
        ['<Space>ff'] = { '<cmd>lua vim.lsp.buf.formatting()<CR>', 'File formatting' },
    }, { buffer = bufnr })

    whichkey.register({
        ['<Space>ff'] = { '<cmd>lua vim.lsp.buf.range_formatting()<CR>', 'File formatting with range' },
    }, { buffer = bufnr, mode = 'v' })
end
