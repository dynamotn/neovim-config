; extends

; `subgraph`, `loop`, `opt` and `rect` keep their statement node while the
; block is open and report `end` as missing, so `@endable` can tell a finished
; block from an unfinished one.
;
; `alt` and `par` expect an `else`/`and` branch, so the parser drops them into
; an ERROR instead and there is nothing to hand to `@endable`.

((flow_stmt_subgraph
  (flow_vertex_text) @cursor) @endable @indent
  (#endwise! "end"))

((sequence_stmt_loop
  (sequence_text) @cursor) @endable @indent
  (#endwise! "end"))

((sequence_stmt_opt
  (sequence_text) @cursor) @endable @indent
  (#endwise! "end"))

((sequence_stmt_rect
  (sequence_text) @cursor) @endable @indent
  (#endwise! "end"))

((ERROR
  .
  "alt" @indent
  .
  (sequence_text) @cursor
  .)
  (#endwise! "end"))

((ERROR
  .
  "par" @indent
  .
  (sequence_text) @cursor
  .)
  (#endwise! "end"))
