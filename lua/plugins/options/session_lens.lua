local present, lens = pcall(require, 'session-lens')

if not present then
    return
end

lens.setup({})

require('telescope').load_extension('session-lens')
