; extends

; Only the directives that take no argument are here, and that is a limit of
; the plugin rather than of the grammar.
;
; Before it runs this query, the plugin asks the parser which language owns the
; position of the last non-whitespace character before the cursor, as a
; zero-width range. For `@if ($x)` that character is the closing paren at
; column 7, and the `php_only` injection over `(parameter)` spans columns 5 to
; 7 -- a zero-width range on that end boundary counts as contained, so the
; plugin looks for a `php_only` endwise query, finds none and gives up. Every
; directive whose line ends in `)` is unreachable for that reason; widening or
; narrowing the injection only moves the problem or costs PHP highlighting
; inside the directive.
;
; `@php`, `@auth` and the rest end on their own `directive_start`, which is
; plain Blade, so they work. The parser leaves them in an ERROR -- it pairs
; only the directives it can see an argument list for -- which is why these
; patterns carry no `@endable`.

((ERROR
  .
  (directive_start) @indent @_d @cursor)
  (#eq? @_d "@php")
  (#endwise! "@endphp"))

((ERROR
  .
  (directive_start) @indent @_d @cursor)
  (#eq? @_d "@auth")
  (#endwise! "@endauth"))

((ERROR
  .
  (directive_start) @indent @_d @cursor)
  (#eq? @_d "@guest")
  (#endwise! "@endguest"))

((ERROR
  .
  (directive_start) @indent @_d @cursor)
  (#eq? @_d "@verbatim")
  (#endwise! "@endverbatim"))

((ERROR
  .
  (directive_start) @indent @_d @cursor)
  (#eq? @_d "@once")
  (#endwise! "@endonce"))

((_
  .
  (directive_start) @indent @_d @cursor) @endable
  (#eq? @_d "@production")
  (#endwise! "@endproduction" "" "directive_end"))
