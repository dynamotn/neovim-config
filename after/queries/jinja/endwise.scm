; extends

; An unterminated tag parses as an ERROR wrapping the `{%`, the statement and
; the `%}`; the `<x>_block` nodes only exist once the closing tag is there.
; Every opener carries its own statement node, so one pattern per end tag is
; enough -- no suffix directive needed.
;
; `{% else %}` and `{% elif %}` sit in a nested `else_block`/`elif_block`, so
; their `%}` is not a direct child of the ERROR and does not match: pressing
; enter on those lines adds nothing, the same way `else` behaves elsewhere.

((ERROR
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (if_statement)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#endwise! "{% endif %}"))

((ERROR
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (for_statement)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#endwise! "{% endfor %}"))

((ERROR
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (block_statement)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#endwise! "{% endblock %}"))

((ERROR
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (macro_statement)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#endwise! "{% endmacro %}"))

((ERROR
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (call_statement)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#endwise! "{% endcall %}"))

((ERROR
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (filter_statement)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#endwise! "{% endfilter %}"))

((ERROR
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (set_block_statement)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#endwise! "{% endset %}"))

((ERROR
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (with_statement)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#endwise! "{% endwith %}"))

((ERROR
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (autoescape_statement)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#endwise! "{% endautoescape %}"))

((ERROR
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (trans_statement)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#endwise! "{% endtrans %}"))

; `{% raw %}` keeps its own node even while unterminated, with `raw_end`
; missing rather than the whole block collapsing into an ERROR.
((raw_block
  (raw_start) @cursor @indent) @endable
  (#endwise! "{% endraw %}" "" "raw_end"))
