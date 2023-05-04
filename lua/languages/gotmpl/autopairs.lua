return function(filetypes, rule)
  return {
    -- Add parentheses in function
    rule('{', '{  }}', filetypes):set_end_pair_length(3),
  }
end
