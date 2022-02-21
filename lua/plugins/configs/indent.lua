local present, indent = pcall(require, 'indent_guides')

if not present then
    return
end

local dark_gui_colors = { '#3D4148', '#50545A' }
local light_gui_colors = { '#E1E1E1', '#CACACA' }

indent.setup({
    indent_guide_size = 1,
    even_colors = vim.go.background == 'dark' and {
        fg = dark_gui_colors[1],
        bg = dark_gui_colors[2]
    } or {
        fg = light_gui_colors[1],
        bg = light_gui_colors[2],
    },
    odd_colors = vim.go.background == 'dark' and {
        fg = dark_gui_colors[2],
        bg = dark_gui_colors[1]
    } or {
        fg = light_gui_colors[2],
        bg = light_gui_colors[1],
    },
})
