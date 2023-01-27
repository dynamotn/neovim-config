local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ['<Esc>'] = actions.close, -- Esc to quit in insert mode
        ['<C-u>'] = false, -- Clear prompt
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
    },
  },
})

telescope.load_extension('fzf')
