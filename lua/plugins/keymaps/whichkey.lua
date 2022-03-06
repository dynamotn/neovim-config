return {
    -- Space key {
    ['<Space>'] = { name = 'Dynamo Trigger' },
    ['<Space>b'] = { name = 'Buffer' },
    ['<Space>d'] = { name = 'Debug / Quick fix / Test' },

    -- E key
    ['<Space>e'] = { name = 'Diagnostic / Error' },
    ['<Space>en'] = { '<cmd>lua vim.diagnostic.goto_next()<CR>', 'Next diagnostic' },
    ['<Space>ep'] = { '<cmd>lua vim.diagnostic.goto_prev()<CR>', 'Previous diagnostic' },

    ['<Space>f'] = { name = 'File' },
    ['<Space>p'] = { name = 'Project' },
    ['<Space>s'] = { name = 'Search' },
    ['<Space>l'] = { name = 'Language tool' },
    ['<Space>t'] = { name = 'Tab' },
    ['<Space>w'] = { name = 'Window' },
    ['<Space>x'] = { name = 'Text manipulation' },
    ------------ }

    -- Leader key {
    ['<leader>'] = { name = 'Secondary Trigger' },
    ------------- }
}
