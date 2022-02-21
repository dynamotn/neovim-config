local present, lualine = pcall(require, 'lualine')

if not present then
    return
end

lualine.setup({
    options = {
        theme = 'onedark',
        disabled_filetypes = {
            'NvimTree',
        },
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
            {
                'filename',
                path = 1, -- Relative path
            },
        },
        lualine_x = { 'filetype' },
        lualine_y = {
            {
                'encoding',
                separator = { left = '', right = '' }, -- Not use powerline between encoding and file format
            },
            'fileformat',
        },
        lualine_z = { 'progress', 'location' },
    },
    extensions = { 'quickfix', 'chadtree' },
})
