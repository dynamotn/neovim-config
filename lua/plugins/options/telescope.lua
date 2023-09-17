local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ['<c-t>'] = function(...)
          return require('trouble.providers.telescope').open_with_trouble(...)
        end,
        ['<a-t>'] = function(...)
          return require('trouble.providers.telescope').open_selected_with_trouble(...)
        end,
        ['<a-i>'] = function()
          local action_state = require('telescope.actions.state')
          local line = action_state.get_current_line()
          dynamo_telescope('find_files', { no_ignore = true, default_text = line })()
        end,
        ['<a-h>'] = function()
          local action_state = require('telescope.actions.state')
          local line = action_state.get_current_line()
          dynamo_telescope('find_files', { hidden = true, default_text = line })()
        end,
        ['<C-Down>'] = function(...)
          return require('telescope.actions').cycle_history_next(...)
        end,
        ['<C-Up>'] = function(...)
          return require('telescope.actions').cycle_history_prev(...)
        end,
        ['<C-f>'] = function(...)
          return require('telescope.actions').preview_scrolling_down(...)
        end,
        ['<C-b>'] = function(...)
          return require('telescope.actions').preview_scrolling_up(...)
        end,
      },
      n = {
        ['q'] = function(...)
          return require('telescope.actions').close(...)
        end,
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
