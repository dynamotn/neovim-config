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
}

coq.Snips('compile')
coq.Now(unpack({ '--shut-up' }))

local augroup = require('misc.augroup')
augroup.enable_snippet_compiling()
