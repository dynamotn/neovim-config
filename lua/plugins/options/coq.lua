local present, coq = pcall(require, 'coq')

if not present then
    return
end

vim.g.coq_settings = {
    keymap = { recommended = false },
    clients = {
        tabnine = { enabled = true },
        snippets = { user_path = vim.fn.expand('$HOME/.config/nvim/snippets') },
    },
    display = {
        preview = {
            positions = { south = 1, north = 2, west = 3, east = 4 },
            x_max_len = 200,
        },
    },
}

coq.Snips('compile')
coq.Now(unpack({ '--shut-up' }))

local augroup = require('misc.augroup')
augroup.enable_snippet_compiling()
