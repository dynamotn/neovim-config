return function(filetypes, rule)
  return {
    -- Add parentheses in function
    rule('{{', '  }', filetypes):set_end_pair_length(2),
    rule('{-', '{-  }', filetypes)
      :replace_endpair(function(_)
        return '<BS><BS>{{-  }'
      end)
      :set_end_pair_length(2),
  }
end
