; extends

; An unterminated expression takes the whole clause down with it, so there is
; no `case_expr` or `receive_expr` to match yet -- only a flat ERROR whose last
; child is the token that was just typed. Every one of these closes with `end`.

((ERROR
  "case" @indent
  .
  (_)
  .
  "of" @cursor
  .)
  (#endwise! "end"))

((ERROR
  "if" @indent
  .
  (guard)
  .
  "->" @cursor
  .)
  (#endwise! "end"))

((ERROR
  "fun" @indent
  .
  (expr_args)
  .
  "->" @cursor
  .)
  (#endwise! "end"))

((ERROR
  "receive" @indent @cursor
  .)
  (#endwise! "end"))

((ERROR
  "begin" @indent @cursor
  .)
  (#endwise! "end"))

((ERROR
  "try" @indent @cursor
  .)
  (#endwise! "end"))

((ERROR
  "maybe" @indent @cursor
  .)
  (#endwise! "end"))
