; extends

; A `CASE` keeps its node while open and reports `keyword_end` as missing, so
; `@endable` can tell it apart from a finished one. A bare `BEGIN` has nothing
; to attach to yet and lands in an ERROR.

((case
  (keyword_then)
  .
  (_) @cursor) @endable @indent
  (#endwise! "END" "" "keyword_end"))

((ERROR
  .
  (keyword_begin) @indent @cursor
  .)
  (#endwise! "END;"))
