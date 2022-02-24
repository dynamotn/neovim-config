vim.g.coq_settings = {
    auto_start = 'shut-up',
    keymap = { recommended = false },
    clients = {
        tabnine = { enabled = true },
    }
}
local present, coq = pcall(require, 'coq')

if not present then
    return
end
