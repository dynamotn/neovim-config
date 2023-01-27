return function(filetypes, rule, cond, _)
  return {
    -- Add metadata code block
    rule('@code%s.+$', '@end', filetypes)
      :use_regex(true)
      :end_wise(cond.is_end_line())
      :with_cr(nil),
    rule('@data%s.+$', '@end', filetypes)
      :use_regex(true)
      :end_wise(cond.is_end_line())
      :with_cr(nil),
    rule('@table$', '@end', filetypes)
      :use_regex(true)
      :end_wise(cond.is_end_line())
      :with_cr(nil),
    rule('@image%s.+$', '@end', filetypes)
      :use_regex(true)
      :end_wise(cond.is_end_line())
      :with_cr(nil),
    rule('@embed%s.+$', '@end', filetypes)
      :use_regex(true)
      :end_wise(cond.is_end_line())
      :with_cr(nil),
    rule('@math$', '@end', filetypes)
      :use_regex(true)
      :end_wise(cond.is_end_line())
      :with_cr(nil),
    rule('@document.*$', '@end', filetypes)
      :use_regex(true)
      :end_wise(cond.is_end_line())
      :with_cr(nil),
  }
end
