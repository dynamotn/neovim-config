; extends

; Like Twig, the HEEx grammar keeps every `<% ... %>` flat: the closing
; `<% end %>` is just another `directive`, not a child of the one that opened
; the block. Nothing can serve as `@endable`, so pressing enter at the end of
; an opener that is already closed adds a second `<% end %>`.
;
; The grammar does mark openers, though: `partial_expression_value` holds `do`
; or `->` for those, `else` for a continuation, and a closing tag gets
; `ending_expression_value` instead -- so neither `<% else %>` nor `<% end %>`
; matches.

((directive
  .
  [
    "<%"
    "<%="
  ] @indent
  .
  (partial_expression_value
    [
      "do"
      "->"
    ])
  .
  "%>" @cursor)
  (#endwise! "<% end %>"))
