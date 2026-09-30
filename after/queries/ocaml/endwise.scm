; extends

; `sig`, `begin`, `object` and `do` keep their node while open and report the
; closing keyword as missing, so `@endable` can tell a finished block from an
; unfinished one. `struct` is the exception: with nothing after it the parser
; drops the whole module binding into an ERROR, so it needs a pattern that
; matches `struct` as the ERROR's last child instead.

((structure
  "struct" @cursor) @endable @indent
  (#endwise! "end"))

((signature
  "sig" @cursor) @endable @indent
  (#endwise! "end"))

((object_expression
  "object" @cursor) @endable @indent
  (#endwise! "end"))

((unit
  "begin" @cursor) @endable @indent
  (#endwise! "end"))

((do_clause
  "do" @cursor) @endable @indent
  (#endwise! "done"))

((ERROR
  "struct" @indent @cursor
  .)
  (#endwise! "end"))
