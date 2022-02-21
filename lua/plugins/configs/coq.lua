vim.g.coq_settings = { auto_start = 'shut-up' }
local present, coq = pcall(require, 'coq')

if not present then
    return
end
