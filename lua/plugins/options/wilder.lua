local present, wilder = pcall(require, 'wilder')

if not present then
    return
end

wilder.setup({
    modes = { ':', '/', '?' },
})

local highlighters = {
    wilder.basic_highlighter(),
}

local popupmenu_renderer = wilder.popupmenu_renderer(wilder.popupmenu_palette_theme({
    highlighter = highlighters,
    highlights = {
        accent = wilder.make_hl('WilderAccent', 'Pmenu', { { a = 1 }, { a = 1 }, { foreground = '#f4468f' } }),
    },
    pumblend = 20,
    border = 'rounded',
    prompt_position = 'bottom',
    empty_message = wilder.popupmenu_empty_message_with_spinner(),
    left = {
        ' ',
        wilder.popupmenu_devicons(),
        wilder.popupmenu_buffer_flags({
            flags = ' a + ',
            icons = { ['+'] = '', a = '', h = '' },
        }),
    },
    right = {
        ' ',
        wilder.popupmenu_scrollbar(),
    },
}))

wilder.set_option(
    'renderer',
    wilder.renderer_mux({
        [':'] = popupmenu_renderer,
        ['/'] = popupmenu_renderer,
        substitute = popupmenu_renderer,
    })
)

wilder.set_option('pipeline', {
    wilder.debounce(10),
    wilder.branch(
        wilder.python_file_finder_pipeline({
            file_command = vim.fn.executable('fd') == 1 and { 'fd', '-tf' } or {
                'find',
                '.',
                '-type',
                'f',
                '-printf',
                '%P\n',
            },
            dir_command = vim.fn.executable('fd') == 1 and { 'fd', '-td' } or {
                'find',
                '.',
                '-type',
                'd',
                '-printf',
                '%P\n',
            },
            filters = { 'fuzzy_filter', 'difflib_sorter' },
        }),
        wilder.substitute_pipeline({
            pipeline = wilder.python_search_pipeline({
                skip_cmdtype_check = 1,
                pattern = wilder.python_fuzzy_pattern({
                    start_at_boundary = 0,
                }),
            }),
        }),
        wilder.cmdline_pipeline({
            language = 'python',
            fuzzy = 1,
        }),
        {
            wilder.check(function(_, x)
                return x == ''
            end),
            wilder.history(),
        },
        wilder.python_search_pipeline({
            skip_cmdtype_check = 1,
            pattern = wilder.python_fuzzy_pattern({
                start_at_boundary = 0,
            }),
            sorter = wilder.python_difflib_sorter(),
            engine = 're',
        })
    ),
})
