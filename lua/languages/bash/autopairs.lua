return function(filetypes, rule)
    return {
        -- Add parentheses in function
        rule('_.*%(%)$', ' { }', filetypes):use_regex(true):set_end_pair_length(0),
    }
end
