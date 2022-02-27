return function(filetypes, rule, cond)
    return {
        -- Add parentheses in arrow function
        rule('=>', ' {  }', filetypes)
            :replace_endpair(function(opts)
                local prev_3char = opts.line:sub(opts.col - 3, opts.col - 2)
                local next_char = opts.line:sub(opts.col, opts.col)
                if prev_3char:match('%)$') then
                    return '<BS><BS> => {  }' .. next_char
                end
                return ' {  }'
            end)
            :set_end_pair_length(2),
    }
end
