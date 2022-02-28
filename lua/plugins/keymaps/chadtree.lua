vim.api.nvim_set_var('chadtree_settings', {
    ['keymap.v_split'] = { 'v' },
    ['keymap.h_split'] = { 'V' },
    ['keymap.rename'] = { 'm' },
})

return {
    ['<F1>'] = { '<cmd>CHADopen<CR>', 'File explorer' },
    ['<Space>ft'] = { '<cmd>CHADopen<CR>', 'File explorer' },
}
