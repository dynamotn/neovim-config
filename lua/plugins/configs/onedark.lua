local present, onedark = pcall(require, 'onedark')

if not present then
    return
end

onedark.setup({
    style = 'cool',
    term_colors = false,
    code_style = {
        comments = 'italic',
        keywords = 'italic',
        functions = 'bold',
        strings = 'none',
        variables = 'none',
    },
})

onedark.load()
