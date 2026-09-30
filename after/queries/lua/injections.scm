; extends

; vim.fn.system('...'), vim.system('...')
((function_call
  name: (dot_index_expression) @_name
  arguments: (arguments
    (string
      content: (string_content) @injection.content)))
  (#any-of? @_name "vim.fn.system" "vim.system")
  (#set! injection.language "bash"))
