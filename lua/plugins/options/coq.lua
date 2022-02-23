vim.g.coq_settings = {
    auto_start = 'shut-up'
    keymap = { recommended = false }
}
local present, coq = pcall(require, 'coq')

if not present then
    return
end
