local present, lspsaga = pcall(require, 'lspsaga')

if not present then
    return
end

lspsaga.setup({
    debug = DEBUG,
    code_action_icon = '💡',
    code_action_prompt = {
        sign = false,
    },
    finder_action_keys = {
        open = 'o',
        vsplit = 's',
        split = 'i',
        quit = 'q',
        scroll_down = '<C-d>',
        scroll_up = '<C-u>',
    },
    rename_output_qflist = {
        enable = true,
        auto_open_qflist = true,
    },
})
