return {
  { 'echasnovski/mini.pairs', enabled = false }, -- Disable mini.pairs from LazyVim
  {
    -- Automatically insert/delete brackets, parentheses, quotes...
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      check_ts = true, -- Check grammar by TreeSitter
      enable_abbr = true, -- Enable abbreviation
      fast_wrap = {}, -- Use default FastWrap
    },
    config = function(_, plugin_opts)
      local autopairs = require('nvim-autopairs')
      autopairs.setup(plugin_opts)

      local rule = require('nvim-autopairs.rule')
      local cond = require('nvim-autopairs.conds')
      local ts_cond = require('nvim-autopairs.ts-conds')

      -- See rules API: https://github.com/windwp/nvim-autopairs/wiki/Rules-API
      autopairs.add_rules({
        -- Add spaces between parentheses
        rule(' ', ' ')
          :with_pair(cond.done())
          :replace_endpair(function(opts)
            local pair = opts.line:sub(opts.col - 1, opts.col)
            if vim.tbl_contains({ '()', '{}', '[]' }, pair) then
              return ' ' -- it return space here
            end
            return '' -- return empty
          end)
          :with_move(cond.none())
          :with_cr(cond.none())
          :with_del(function(opts)
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local context = opts.line:sub(col - 1, col + 2)
            return vim.tbl_contains({ '(  )', '{  }', '[  ]' }, context)
          end),
        rule('', ' )')
          :with_pair(cond.none())
          :with_move(function(opts) return opts.char == ')' end)
          :with_cr(cond.none())
          :with_del(cond.none())
          :use_key(')'),
        rule('', ' }')
          :with_pair(cond.none())
          :with_move(function(opts) return opts.char == '}' end)
          :with_cr(cond.none())
          :with_del(cond.none())
          :use_key('}'),
        rule('', ' ]')
          :with_pair(cond.none())
          :with_move(function(opts) return opts.char == ']' end)
          :with_cr(cond.none())
          :with_del(cond.none())
          :use_key(']'),

        -- Add space on equal sign
        rule(
            '=',
            ' ',
            {
              '-sh',
              '-sh.ebuild',
              '-bats',
              '-sh.PKGBUILD',
              '-yaml',
              '-dockerfile',
            }
          )
          :with_pair(cond.not_inside_quote())
          :with_pair(function(opts)
            local last_char = opts.line:sub(opts.col - 1, opts.col - 1)
            if last_char:match('[%w%=%s]') then return true end
            return false
          end)
          :replace_endpair(function(opts)
            local prev_2char = opts.line:sub(opts.col - 2, opts.col - 1)
            local next_char = opts.line:sub(opts.col, opts.col)
            next_char = next_char == ' ' and '' or ' '
            if prev_2char:match('%w$') then return '<BS> =' .. next_char end
            if prev_2char:match('%=$') then return next_char end
            if prev_2char:match('=') then return '<BS><BS>=' .. next_char end
            return ''
          end)
          :set_end_pair_length(0)
          :with_move(cond.none())
          :with_del(cond.none()),

        -- Add space after comma when have following text after comma
        rule(',', ' ')
          :replace_endpair(function(opts)
            local next_char = opts.line:sub(opts.col, opts.col)
            if next_char:match('%w$') then return ' ' end
            return ''
          end)
          :set_end_pair_length(0),
      })

      -- Auto pair rules per filetype
      local languages_list = vim.tbl_filter(
        function(config) return config.autopairs end,
        require('config.languages')
      )
      for _, config in pairs(languages_list) do
        autopairs.add_rules(
          config.autopairs(config.filetypes, rule, cond, ts_cond)
        )
      end
    end,
  },
  {
    -- Accept auto brackets from autopairs for completion
    'saghen/blink.cmp',
    opts = { completion = { accept = { auto_brackets = { enabled = true } } } },
  },
}
