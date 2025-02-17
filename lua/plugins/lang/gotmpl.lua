local filetypes = require('languages.list').gotmpl

return vim.list_contains(_G.enabled_languages, 'python')
    and {
      {
        'nvim-autopairs',
        -- config = function(_, _)
        --   local autopairs = require('nvim-autopairs')
        --   local rule = require('nvim-autopairs.rule')
        --   autopairs.add_rules({
        --     -- Add parentheses in function
        --     rule('{{', '  }', filetypes):set_end_pair_length(2),
        --     rule('{-', '{-  }', filetypes)
        --       :replace_endpair(function(_)
        --         return '<BS><BS>{{-  }'
        --       end)
        --       :set_end_pair_length(2),
        --   })
        -- end,
      },
    }
  or {}
