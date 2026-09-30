; extends

; An unterminated tag leaves the `{%`, its `tag_name`, the arguments and the
; `%}` as loose children of an ERROR -- there is no node wrapping one tag.
;
; The arguments are therefore spelled out as an explicit alternation rather
; than `_*`. A wildcard would happily run past the tag's own `%}` and pair a
; `tag_name` with the closing brace of a *later* unterminated tag in the same
; ERROR, which would answer `{% block %}` with `{% endif %}`. The list below
; holds every node an argument can be and, crucially, neither `content` nor
; `{%`, so a match can never leave the tag it started in.
;
; `{% cache %}` and friends get their own `unpaired_statement` node, and
; `{% comment %}` an anonymous `comment` token instead of a `tag_name`.

; -- tags the parser leaves in an ERROR --------------------------------------

((ERROR
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor)
  (#eq? @_t "if")
  (#endwise! "{% endif %}"))

((ERROR
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor)
  (#eq? @_t "for")
  (#endwise! "{% endfor %}"))

((ERROR
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor)
  (#eq? @_t "block")
  (#endwise! "{% endblock %}"))

((ERROR
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor)
  (#eq? @_t "with")
  (#endwise! "{% endwith %}"))

((ERROR
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor)
  (#eq? @_t "autoescape")
  (#endwise! "{% endautoescape %}"))

((ERROR
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor)
  (#eq? @_t "blocktrans")
  (#endwise! "{% endblocktrans %}"))

((ERROR
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor)
  (#eq? @_t "blocktranslate")
  (#endwise! "{% endblocktranslate %}"))

((ERROR
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor)
  (#eq? @_t "filter")
  (#endwise! "{% endfilter %}"))

((ERROR
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor)
  (#eq? @_t "spaceless")
  (#endwise! "{% endspaceless %}"))

((ERROR
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor)
  (#eq? @_t "verbatim")
  (#endwise! "{% endverbatim %}"))

((ERROR
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor)
  (#eq? @_t "ifchanged")
  (#endwise! "{% endifchanged %}"))

; -- `comment` is a token of its own, not a `tag_name` ------------------------

((ERROR
  .
  "{%" @indent
  .
  "comment"
  .
  "%}" @cursor
  .)
  (#endwise! "{% endcomment %}"))

; -- tags the parser files under `unpaired_statement` ------------------------

((unpaired_statement
  .
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor
  .)
  (#eq? @_t "cache")
  (#endwise! "{% endcache %}"))

((unpaired_statement
  .
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor
  .)
  (#eq? @_t "localize")
  (#endwise! "{% endlocalize %}"))

((unpaired_statement
  .
  "{%" @indent
  .
  (tag_name) @_t
  .
  [
    (variable)
    (keyword)
    (keyword_operator)
    (operator)
    (number)
    (string)
    (filter)
    ","
    "="
    "|"
  ]*
  .
  "%}" @cursor
  .)
  (#eq? @_t "language")
  (#endwise! "{% endlanguage %}"))
