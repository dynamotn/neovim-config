; extends

; Upstream closes only `do` blocks; these close an anonymous `fn ... ->`.
;
; How much of the `fn` survives depends on what surrounds it. On its own, or
; on the right of a match, it keeps its `anonymous_function` node and reports
; `end` as missing, so `@endable` can tell a closed one from an open one.
; Inside an unclosed block the node survives without that missing `end`, and
; as a call argument it falls apart into an ERROR holding a bare `fn`
; token. Neither of those has an `@endable`, so both are pinned to the
; last child: a closed `fn` would end on its own `end` instead.

((anonymous_function
  "fn" @indent
  .
  (stab_clause
    "->" @cursor)) @endable
  (#endwise! "end"))

((ERROR
  (anonymous_function
    "fn" @indent
    .
    (stab_clause
      "->" @cursor)
    .)
  .)
  (#endwise! "end"))

((ERROR
  "fn" @indent
  .
  (stab_clause
    "->" @cursor)
  .)
  (#endwise! "end"))

; A single bare parameter is not even given a `stab_clause`.
((ERROR
  "fn" @indent
  .
  (identifier)
  .
  (operator_identifier
    "->" @cursor)
  .)
  (#endwise! "end"))
