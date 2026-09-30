; extends

; An unclosed directive stays in an ERROR; the `conditional` node that holds
; the `endif` only forms once it is written. `define` gets no directive node of
; its own, so its pattern matches the ERROR's children directly.

((ERROR
  (ifeq_directive
    ")" @cursor
    .) @indent)
  (#endwise! "endif"))

((ERROR
  (ifneq_directive
    ")" @cursor
    .) @indent)
  (#endwise! "endif"))

((ERROR
  (ifdef_directive
    (word) @cursor
    .) @indent)
  (#endwise! "endif"))

((ERROR
  (ifndef_directive
    (word) @cursor
    .) @indent)
  (#endwise! "endif"))

((ERROR
  .
  "define" @indent
  .
  (word) @cursor
  .)
  (#endwise! "endef"))
