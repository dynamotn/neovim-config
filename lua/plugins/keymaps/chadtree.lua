vim.api.nvim_set_var('chadtree_settings', {
    ['keymap.v_split'] = { 'v' },
    ['keymap.h_split'] = { 'V' },
    ['keymap.rename'] = { 'm' },
})

return {
    ['<F1>'] = { '<cmd>CHADopen<cr>', 'File explorer' },
    ['<space>ft'] = { '<cmd>CHADopen<cr>', 'File explorer' },
}
