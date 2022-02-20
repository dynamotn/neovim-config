local present, indent = pcall(require, 'indent_guides')

if not present then
    return
end

indent.setup({
    indent_guide_size = 8,
    even_colors = vim.go.background == 'dark' and { fg = 'grey30', bg = 'grey15' } or { fg = 'grey85', bg = 'grey70' },
    odd_colors = vim.go.background == 'dark' and { fg = 'grey15', bg = 'grey30' } or { fg = 'grey70', bg = 'grey85' },
})
