require('nvim-treesitter.configs').setup({
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = {
          query = '@function.outer',
          desc = 'outer part of a function',
        },
        ['if'] = {
          query = '@function.inner',
          desc = 'inner part of a function',
        },
        ['ac'] = { query = '@class.outer', desc = 'outer part of a class' },
        ['ic'] = { query = '@class.inner', desc = 'inner part of a class' },
      },
      selection_modes = {
        ['@parameter.outer'] = 'v',
        ['@function.outer'] = 'V',
        ['@class.outer'] = '<c-v>',
      },
      include_surrounding_whitespace = true,
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>sp'] = {
          query = '@parameter.inner',
          desc = 'Swap to next parameter',
        },
      },
      swap_previous = {
        ['<leader>sP'] = {
          query = '@parameter.inner',
          desc = 'Swap to previous parameter',
        },
      },
    },
  },
})
