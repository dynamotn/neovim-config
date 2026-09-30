; extends

; The Twig grammar does not pair an opening tag with its closing one: every
; directive, `{% endif %}` included, is a flat `statement_directive`. There is
; therefore no node that can be handed to the plugin as `@endable`, and no way
; to tell an unterminated block from a terminated one -- pressing enter at the
; end of a block opener that already has its closing tag adds a second one.
;
; `{% else %}` and `{% elseif %}` parse as an `if_statement` too, so the
; keyword is compared against `if` rather than matched by node type alone.

((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (if_statement
    (conditional) @_kw)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#eq? @_kw "if")
  (#endwise! "{% endif %}"))

((statement_directive
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

((statement_directive
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

; `{% set x %}` opens a block; `{% set x = 1 %}` assigns and closes nothing.
((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (assignment_statement
    (keyword)
    .
    (variable)
    .)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#endwise! "{% endset %}"))

((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (tag_statement
    (tag) @_tag)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#eq? @_tag "block")
  (#endwise! "{% endblock %}"))

((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (tag_statement
    (tag) @_tag)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#eq? @_tag "embed")
  (#endwise! "{% endembed %}"))

((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (tag_statement
    (tag) @_tag)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#eq? @_tag "apply")
  (#endwise! "{% endapply %}"))

((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (tag_statement
    (tag) @_tag)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#eq? @_tag "autoescape")
  (#endwise! "{% endautoescape %}"))

((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (tag_statement
    (tag) @_tag)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#eq? @_tag "with")
  (#endwise! "{% endwith %}"))

((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (tag_statement
    (tag) @_tag)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#eq? @_tag "verbatim")
  (#endwise! "{% endverbatim %}"))

((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (tag_statement
    (tag) @_tag)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#eq? @_tag "sandbox")
  (#endwise! "{% endsandbox %}"))

((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (tag_statement
    (tag) @_tag)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#eq? @_tag "cache")
  (#endwise! "{% endcache %}"))

((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (tag_statement
    (tag) @_tag)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#eq? @_tag "filter")
  (#endwise! "{% endfilter %}"))

((statement_directive
  .
  [
    "{%"
    "{%-"
  ] @indent
  .
  (tag_statement
    (tag) @_tag)
  .
  [
    "%}"
    "-%}"
  ] @cursor)
  (#eq? @_tag "trans")
  (#endwise! "{% endtrans %}"))
