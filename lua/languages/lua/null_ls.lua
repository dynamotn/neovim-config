return {
    tools = {
        'luacheck',
        'stylua',
    },
    sources = {
        { 'refactoring', 'code_actions', is_external_tool = false },
        { 'luacheck', 'diagnostics' },
        { 'stylua', 'formatting' },
    },
}
