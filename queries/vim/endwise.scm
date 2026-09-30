; Deliberately no `; extends`: this replaces the upstream query instead of
; adding to it. Neovim takes the first file without `extends` it finds on the
; runtimepath as the base query, and the plugin's own file comes before
; anything under `after/`, so the override has to live here, in `queries/`.
;
; Upstream ends a function through the suffix argument of `#endwise!`, which
; hands the directive a capture and pastes that capture's text after the end
; text -- `end` + `func`. The plugin reads the capture as a single node, while
; Neovim 0.11+ passes a list of nodes, so the directive errors out instead of
; inserting anything. Splitting the opener into two patterns needs no suffix.
;
; Vim accepts any abbreviation of `endfunction`, whichever abbreviation opened
; the function, so everything short of the full `function` gets `endfunc`.

((if_statement
  condition: (_) @cursor) @endable @indent
  (#endwise! "endif"))

((for_loop
  iter: (_) @cursor) @indent
  (#endwise! "endfor"))

((while_loop
  condition: (_) @cursor) @indent
  (#endwise! "endwhile"))

((try_statement
  "try" @cursor) @endable @indent
  (#endwise! "endtry"))

((function_definition
  "function" @indent
  (function_declaration
    parameters: (_) @cursor)
  .
  [
    "abort"
    "closure"
    "dict"
    "range"
  ]* @cursor) @endable
  (#eq? @indent "function")
  (#endwise! "endfunction"))

((function_definition
  "function" @indent
  (function_declaration
    parameters: (_) @cursor)
  .
  [
    "abort"
    "closure"
    "dict"
    "range"
  ]* @cursor) @endable
  (#not-eq? @indent "function")
  (#endwise! "endfunc" "" "endfunction"))

((ERROR
  ("if" @indent
    .
    (_) @cursor))
  (#endwise! "endif"))

((ERROR
  ("for" @indent
    .
    (_)
    .
    "in"
    .
    (_) @cursor))
  (#endwise! "endfor"))

((ERROR
  ("while" @indent
    .
    (_) @cursor))
  (#endwise! "endwhile"))

((ERROR
  ("try" @indent @cursor))
  (#endwise! "endtry"))

((ERROR
  ("function" @indent
    (bang)?
    .
    (function_declaration
      parameters: (_) @cursor)
    [
      "abort"
      "closure"
      "dict"
      "range"
    ]* @cursor))
  (#eq? @indent "function")
  (#endwise! "endfunction"))

((ERROR
  ("function" @indent
    (bang)?
    .
    (function_declaration
      parameters: (_) @cursor)
    [
      "abort"
      "closure"
      "dict"
      "range"
    ]* @cursor))
  (#not-eq? @indent "function")
  (#endwise! "endfunc"))
