return function(filetypes, rule)
  return {
    -- Add parentheses in function
    rule('^.*%(%)$', ' { }', filetypes):use_regex(true):set_end_pair_length(0),
  }
end
