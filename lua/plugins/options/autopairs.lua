local present, autopairs = pcall(require, 'nvim-autopairs')

if not present then
    return
end

autopairs.setup({
    map_bs = false, -- Not map Backspace key
    map_cr = false, -- Not map Enter key
    check_ts = true, -- Check grammar by TreeSitter
})

local rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

-- See rules API: https://github.com/windwp/nvim-autopairs/wiki/Rules-API
autopairs.add_rules({
    -- Add spaces between parentheses
    rule(' ', ' ')
        :with_pair(function(opts)
            local pair = opts.line:sub(opts.col - 1, opts.col)
            return vim.tbl_contains({ '()', '{}', '[]' }, pair)
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
        :with_move(function(opts)
            return opts.char == ')'
        end)
        :with_cr(cond.none())
        :with_del(cond.none())
        :use_key(')'),
    rule('', ' }')
        :with_pair(cond.none())
        :with_move(function(opts)
            return opts.char == '}'
        end)
        :with_cr(cond.none())
        :with_del(cond.none())
        :use_key('}'),
    rule('', ' ]')
        :with_pair(cond.none())
        :with_move(function(opts)
            return opts.char == ']'
        end)
        :with_cr(cond.none())
        :with_del(cond.none())
        :use_key(']'),

    -- Add space on equal sign
    rule('=', ' ', '-sh')
        :with_pair(cond.not_inside_quote())
        :with_pair(function(opts)
            local last_char = opts.line:sub(opts.col - 1, opts.col - 1)
            if last_char:match('[%w%=%s]') then
                return true
            end
            return false
        end)
        :replace_endpair(function(opts)
            local prev_2char = opts.line:sub(opts.col - 2, opts.col - 1)
            local next_char = opts.line:sub(opts.col, opts.col)
            next_char = next_char == ' ' and '' or ' '
            if prev_2char:match('%w$') then
                return '<BS> =' .. next_char
            end
            if prev_2char:match('%=$') then
                return next_char
            end
            if prev_2char:match('=') then
                return '<BS><BS>=' .. next_char
            end
            return ''
        end)
        :set_end_pair_length(0)
        :with_move(cond.none())
        :with_del(cond.none()),
})

return autopairs
