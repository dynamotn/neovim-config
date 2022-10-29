vim.api.nvim_set_var('chadtree_settings', {
  ['keymap.v_split'] = { 'v' },
  ['keymap.h_split'] = { 'V' },
  ['keymap.rename'] = { 'm' },
})

return {
  ['<F1>'] = { dynamo_cmdcr('CHADopen'), 'File explorer' },
  ['<Space>ft'] = { dynamo_cmdcr('CHADopen'), 'File explorer' },
}
