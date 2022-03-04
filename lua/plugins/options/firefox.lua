if vim.g.started_by_firenvim then
    vim.opt.laststatus = 0
end
vim.g.firenvim_config = {
    localSettings = {
        [ [[.*]] ] = {
            cmdline = 'firenvim',
            content = 'text',
            priority = 0,
            selector = 'textarea:not([readonly]):not([class="handsontableInput"]), div[role="textbox"]',
            takeover = 'always',
        },
        [ [[.*google.com.*]] ] = {
            priority = 9,
            takeover = 'never',
        },
        [ [[.*facebook.com.*]] ] = {
            priority = 9,
            takeover = 'never',
        },
        [ [[.*notion\.so.*]] ] = {
            priority = 9,
            takeover = 'never',
        },
        [ [[.*docs\.google\.com.*]] ] = {
            prioirty = 9,
            takeover = 'never',
        },
        [ [[.*mail\.google\.com.*]] ] = {
            prioirty = 9,
            takeover = 'never',
        },
    },
}
