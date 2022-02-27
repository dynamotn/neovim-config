local present, coq = pcall(require, 'coq')

if not present then
    return
end

vim.g.coq_settings = {
    keymap = { recommended = false },
    clients = {
        tabnine = { enabled = true },
    },
}

coq.Now(unpack({ '--shut-up' }))
