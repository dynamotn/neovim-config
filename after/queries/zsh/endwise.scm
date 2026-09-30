; extends

; See `bash` -- the Zsh grammar is a fork of it, so `if`, `do` and `case`
; behave the same. `case` is the one the parser gives up on rather than
; leaving the closing token missing, so it needs the ERROR variant too.

((if_statement
  "then" @cursor) @endable @indent
  (#endwise! "fi"))

((do_group
  "do" @cursor) @endable @indent
  (#endwise! "done"))

((case_statement
  "in" @cursor) @endable @indent
  (#endwise! "esac"))

((ERROR
  ("case" @indent
    .
    (_)
    .
    "in" @cursor))
  (#endwise! "esac"))
