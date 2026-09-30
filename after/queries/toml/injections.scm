; extends

; `run` of a mise task. A multiline script picks its language from its
; shebang and falls back to bash, as a one-line command always does.
;
; Lua patterns throughout, so the test and the `#gsub!` that extracts the
; language read the shebang the same way; `%S` keeps either from reaching
; past the shebang line into the script itself.

(pair
  (bare_key) @_key
  (string) @injection.content @injection.language
  (#eq? @_key "run")
  (#is-mise?)
  (#lua-match? @injection.language "^\"\"\"%s*#!%S*/env%s+[%w_-]+") ; shebang through env
  (#gsub! @injection.language "^\"\"\"%s*#!%S*/env%s+([%w_-]+).*$" "%1")
  (#offset! @injection.content 0 3 0 -3))

(pair
  (bare_key) @_key
  (string) @injection.content @injection.language
  (#eq? @_key "run")
  (#is-mise?)
  (#lua-match? @injection.language "^\"\"\"%s*#!/%S+%s*\n")
  (#not-lua-match? @injection.language "^\"\"\"%s*#!%S*/env%s")
  (#gsub! @injection.language "^\"\"\"%s*#!%S*/([^/%s]+)%s.*$" "%1")
  (#offset! @injection.content 0 3 0 -3))

(pair
  (bare_key) @_key
  (string) @injection.content
  (#eq? @_key "run")
  (#is-mise?)
  (#lua-match? @injection.content "^\"\"\"")
  (#not-lua-match? @injection.content "^\"\"\"%s*#!")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "bash"))

(pair
  (bare_key) @_key
  (string) @injection.content
  (#eq? @_key "run")
  (#is-mise?)
  (#not-lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "bash"))
