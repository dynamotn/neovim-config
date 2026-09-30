; extends

; An unclosed command leaves the whole construct in an ERROR; the matching
; `<x>_condition` / `<x>_loop` nodes only form once the `end...()` is there.
; The trailing anchor keeps `@cursor` on the command's own closing paren rather
; than on one nested inside its arguments.

((ERROR
  (if_command
    ")" @cursor
    .) @indent)
  (#endwise! "endif()"))

((ERROR
  (foreach_command
    ")" @cursor
    .) @indent)
  (#endwise! "endforeach()"))

((ERROR
  (while_command
    ")" @cursor
    .) @indent)
  (#endwise! "endwhile()"))

((ERROR
  (function_command
    ")" @cursor
    .) @indent)
  (#endwise! "endfunction()"))

((ERROR
  (macro_command
    ")" @cursor
    .) @indent)
  (#endwise! "endmacro()"))

((ERROR
  (block_command
    ")" @cursor
    .) @indent)
  (#endwise! "endblock()"))
