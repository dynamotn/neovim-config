; extends

; See `gotmpl` — the Helm grammar is a fork of the Go template one, so an
; unterminated action shows up the same way, as an ERROR node.
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
