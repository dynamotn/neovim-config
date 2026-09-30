; extends

; An unterminated action parses as an ERROR node, so match its raw children
; rather than `if_action`, `range_action`, ... which only exist once the
; matching `{{ end }}` is present.
((ERROR
  .
  [
    "{{"
    "{{-"
  ] @indent
  .
  [
    "if"
    "range"
    "with"
    "block"
    "define"
  ]
  [
    "}}"
    "-}}"
  ] @cursor)
  (#endwise! "{{ end }}"))
