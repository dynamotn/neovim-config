; extends

; ERB hands the grammar one opaque `code` node per tag and nothing else: an
; opener, `<% else %>` and `<% end %>` are the same shape, and no node pairs a
; tag with its closer. So the Ruby has to be read as text, and -- as in `twig`
; and `heex` -- there is nothing to give `@endable`, which means pressing enter
; at the end of an opener that is already closed adds a second `<% end %>`.
;
; Two shapes open a block: a trailing `do`, with or without block parameters,
; and a leading keyword. A trailing `if` is a modifier, not an opener, so the
; keyword is anchored to the start of the tag.

((directive
  .
  "<%" @indent
  .
  (code) @_c
  .
  "%>" @cursor)
  (#match? @_c "\\v<do>\\s*(\\|[^|]*\\|)?\\s*$")
  (#endwise! "<% end %>"))

((output_directive
  .
  "<%=" @indent
  .
  (code) @_c
  .
  "%>" @cursor)
  (#match? @_c "\\v<do>\\s*(\\|[^|]*\\|)?\\s*$")
  (#endwise! "<% end %>"))

((directive
  .
  "<%" @indent
  .
  (code) @_c
  .
  "%>" @cursor)
  (#match? @_c "\\v^\\s*(if|unless|case|while|until|begin|for|def|class|module)>")
  (#endwise! "<% end %>"))

((output_directive
  .
  "<%=" @indent
  .
  (code) @_c
  .
  "%>" @cursor)
  (#match? @_c "\\v^\\s*(if|unless|case|while|until|begin|for|def|class|module)>")
  (#endwise! "<% end %>"))
