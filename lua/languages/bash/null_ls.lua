return {
    { 'shellcheck', 'code_actions' },
    { 'shellcheck', 'diagnostics' },
    { 'shfmt', 'formatting', with_config = { extra_args = { '-i', '2', '-ci', '-bn', '-sr' } } },
    { 'shellharden', 'formatting' },
}
