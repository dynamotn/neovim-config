; extends

; An unterminated block parses as an ERROR holding the `block_statement_start`;
; the `block_statement` node with its `block_statement_end` only appears once
; `{{/name}}` is there.
;
; The closing tag repeats the helper's name, and the directive that would paste
; a captured name after the end text is the one Neovim 0.11+ broke (see
; `vim/endwise.scm`), so each name needs its own pattern. That covers the
; built-in helpers; a block invoking a custom component gets no closing tag.

((ERROR
  .
  (block_statement_start
    .
    "{{#"
    .
    (identifier) @_name
    "}}" @cursor) @indent)
  (#eq? @_name "if")
  (#endwise! "{{/if}}"))

((ERROR
  .
  (block_statement_start
    .
    "{{#"
    .
    (identifier) @_name
    "}}" @cursor) @indent)
  (#eq? @_name "unless")
  (#endwise! "{{/unless}}"))

((ERROR
  .
  (block_statement_start
    .
    "{{#"
    .
    (identifier) @_name
    "}}" @cursor) @indent)
  (#eq? @_name "each")
  (#endwise! "{{/each}}"))

((ERROR
  .
  (block_statement_start
    .
    "{{#"
    .
    (identifier) @_name
    "}}" @cursor) @indent)
  (#eq? @_name "each-in")
  (#endwise! "{{/each-in}}"))

((ERROR
  .
  (block_statement_start
    .
    "{{#"
    .
    (identifier) @_name
    "}}" @cursor) @indent)
  (#eq? @_name "let")
  (#endwise! "{{/let}}"))

((ERROR
  .
  (block_statement_start
    .
    "{{#"
    .
    (identifier) @_name
    "}}" @cursor) @indent)
  (#eq? @_name "with")
  (#endwise! "{{/with}}"))

((ERROR
  .
  (block_statement_start
    .
    "{{#"
    .
    (identifier) @_name
    "}}" @cursor) @indent)
  (#any-of? @_name "in-element" "-in-element")
  (#endwise! "{{/in-element}}"))

((ERROR
  .
  (block_statement_start
    .
    "{{#"
    .
    (identifier) @_name
    "}}" @cursor) @indent)
  (#eq? @_name "component")
  (#endwise! "{{/component}}"))
