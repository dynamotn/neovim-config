local settings = vim.api.nvim_get_var('chadtree_settings')

settings['view.open_direction'] = 'right'

vim.api.nvim_set_var('chadtree_settings', settings)
