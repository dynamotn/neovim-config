local present, lualine = pcall(require, 'lualine')

if not present then
   return
end

lualine.setup {
    options = {
        theme = 'onedark',
        disabled_filetypes = {
            'NvimTree',
        },
    }
}
