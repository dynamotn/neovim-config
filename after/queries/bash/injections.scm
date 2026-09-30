; extends

; awk '{ print $1 }'
((command
  name: (command_name) @_name
  argument: (raw_string) @injection.content)
  (#any-of? @_name "awk" "gawk" "mawk" "nawk")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "awk"))
