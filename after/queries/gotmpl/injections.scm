; extends

((text) @injection.content
  (#is-bash-file?)
  (#set! injection.language "bash")
  (#set! injection.combined))

((text) @injection.content
  (#is-fish-file?)
  (#set! injection.language "fish")
  (#set! injection.combined))

((text) @injection.content
  (#is-yaml-file?)
  (#set! injection.language "yaml")
  (#set! injection.combined))

((text) @injection.content
  (#is-toml-file?)
  (#set! injection.language "toml")
  (#set! injection.combined))

((text) @injection.content
  (#is-toml-file?)
  (#set! injection.language "ini")
  (#set! injection.combined))

((text) @injection.content
  (#is-js-file?)
  (#set! injection.language "js")
  (#set! injection.combined))

((text) @injection.content
  (#is-python-file?)
  (#set! injection.language "python")
  (#set! injection.combined))

((text) @injection.content
  (#is-lua-file?)
  (#set! injection.language "lua")
  (#set! injection.combined))
