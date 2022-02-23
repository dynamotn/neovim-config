local present, autopair = pcall(require, 'nvim-autopairs')

if not present then
    return
end

autopair.setup({
    map_bs = false,
    map_cr = false,
})

return autopair
