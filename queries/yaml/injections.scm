; Deliberately no `; extends`: this replaces nvim-treesitter's own query rather
; than adding to it. Neovim takes the first file without `extends` it finds on
; the runtimepath as the base query, and this directory comes before the one
; the parsers are installed into, so the override has to live in `queries/`.
;
; Upstream keys every shell injection on the name alone: a `run:` or a
; `script:` is a shell script in any YAML file at all. That is wrong twice
; over. A workflow's `script:` belongs to `actions/github-script` and holds
; JavaScript, which then comes out highlighted as shell; and extending the
; query instead of replacing it would have Neovim parse each script twice,
; once per matching pattern, since the two overlap. Keeping one query means
; each key is claimed once, by the CI flavour that defines it.
;
; `ftdetect/filetype.lua` is what tells the flavours apart -- a workflow is any
; YAML under `.github/workflows/`, whatever it is called -- so the predicates
; ask for the filetype. The Taskfile and Prometheus keys stay unqualified, the
; way upstream had them, because no filetype of their own exists to ask for.
;
; A block scalar keeps its indicator (`|`, `|-`, `>2+`, ...) in the node text,
; and `#offset!` shifts a range by a fixed amount only, so the indicator is
; measured with `#lua-match?` and each pattern skips exactly the length it
; matched. Everything after it is the script, indentation included, which the
; injected language ignores.

((comment) @injection.content
  (#set! injection.language "comment"))

; GitHub Actions: `run:`, always a single scalar. A step that overrides `shell:`
; with something other than bash keeps the plain YAML highlighting.
(block_mapping_pair
  key: (flow_node) @_key
  value: (block_node
    (block_scalar) @injection.content)
  (#eq? @_key "run")
  (#is-gh-action?)
  (#lua-match? @injection.content "^[|>][^%-+%d]")
  (#offset! @injection.content 0 1 0 0)
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: (block_node
    (block_scalar) @injection.content)
  (#eq? @_key "run")
  (#is-gh-action?)
  (#lua-match? @injection.content "^[|>][%-+%d][^%-+%d]")
  (#offset! @injection.content 0 2 0 0)
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: (block_node
    (block_scalar) @injection.content)
  (#eq? @_key "run")
  (#is-gh-action?)
  (#lua-match? @injection.content "^[|>][%-+%d][%-+%d]")
  (#offset! @injection.content 0 3 0 0)
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: (flow_node
    (plain_scalar
      (string_scalar) @injection.content))
  (#eq? @_key "run")
  (#is-gh-action?)
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: (flow_node
    [
      (single_quote_scalar)
      (double_quote_scalar)
    ] @injection.content)
  (#eq? @_key "run")
  (#is-gh-action?)
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "bash"))

; GitLab CI and Azure Pipelines. They share `script:` and neither defines the
; other's remaining keys -- `before_script` and `after_script` are GitLab's,
; `bash` is Azure's -- so one predicate serves both. Every one of them takes a
; sequence as readily as a single scalar, and each item is its own command.
(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (block_node
      (block_scalar) @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (block_node
            (block_scalar) @injection.content))))
  ]
  (#any-of? @_key "script" "before_script" "after_script" "bash")
  (#is-ci-pipeline?)
  (#lua-match? @injection.content "^[|>][^%-+%d]")
  (#offset! @injection.content 0 1 0 0)
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (block_node
      (block_scalar) @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (block_node
            (block_scalar) @injection.content))))
  ]
  (#any-of? @_key "script" "before_script" "after_script" "bash")
  (#is-ci-pipeline?)
  (#lua-match? @injection.content "^[|>][%-+%d][^%-+%d]")
  (#offset! @injection.content 0 2 0 0)
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (block_node
      (block_scalar) @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (block_node
            (block_scalar) @injection.content))))
  ]
  (#any-of? @_key "script" "before_script" "after_script" "bash")
  (#is-ci-pipeline?)
  (#lua-match? @injection.content "^[|>][%-+%d][%-+%d]")
  (#offset! @injection.content 0 3 0 0)
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (flow_node
      (plain_scalar
        (string_scalar) @injection.content))
    (block_node
      (block_sequence
        (block_sequence_item
          (flow_node
            (plain_scalar
              (string_scalar) @injection.content)))))
  ]
  (#any-of? @_key "script" "before_script" "after_script" "bash")
  (#is-ci-pipeline?)
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (flow_node
      [
        (single_quote_scalar)
        (double_quote_scalar)
      ] @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (flow_node
            [
              (single_quote_scalar)
              (double_quote_scalar)
            ] @injection.content))))
  ]
  (#any-of? @_key "script" "before_script" "after_script" "bash")
  (#is-ci-pipeline?)
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "bash"))

; Taskfile: `cmds:` is the sequence, `cmd:` and `sh:` the single commands.
(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (block_node
      (block_scalar) @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (block_node
            (block_scalar) @injection.content))))
  ]
  (#any-of? @_key "cmds" "cmd" "sh")
  (#lua-match? @injection.content "^[|>][^%-+%d]")
  (#offset! @injection.content 0 1 0 0)
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (block_node
      (block_scalar) @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (block_node
            (block_scalar) @injection.content))))
  ]
  (#any-of? @_key "cmds" "cmd" "sh")
  (#lua-match? @injection.content "^[|>][%-+%d][^%-+%d]")
  (#offset! @injection.content 0 2 0 0)
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (block_node
      (block_scalar) @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (block_node
            (block_scalar) @injection.content))))
  ]
  (#any-of? @_key "cmds" "cmd" "sh")
  (#lua-match? @injection.content "^[|>][%-+%d][%-+%d]")
  (#offset! @injection.content 0 3 0 0)
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (flow_node
      (plain_scalar
        (string_scalar) @injection.content))
    (block_node
      (block_sequence
        (block_sequence_item
          (flow_node
            (plain_scalar
              (string_scalar) @injection.content)))))
  ]
  (#any-of? @_key "cmds" "cmd" "sh")
  (#set! injection.language "bash"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (flow_node
      [
        (single_quote_scalar)
        (double_quote_scalar)
      ] @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (flow_node
            [
              (single_quote_scalar)
              (double_quote_scalar)
            ] @injection.content))))
  ]
  (#any-of? @_key "cmds" "cmd" "sh")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "bash"))

; Prometheus Alertmanager: `expr:` is PromQL, not shell.
(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (block_node
      (block_scalar) @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (block_node
            (block_scalar) @injection.content))))
  ]
  (#eq? @_key "expr")
  (#lua-match? @injection.content "^[|>][^%-+%d]")
  (#offset! @injection.content 0 1 0 0)
  (#set! injection.language "promql"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (block_node
      (block_scalar) @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (block_node
            (block_scalar) @injection.content))))
  ]
  (#eq? @_key "expr")
  (#lua-match? @injection.content "^[|>][%-+%d][^%-+%d]")
  (#offset! @injection.content 0 2 0 0)
  (#set! injection.language "promql"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (block_node
      (block_scalar) @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (block_node
            (block_scalar) @injection.content))))
  ]
  (#eq? @_key "expr")
  (#lua-match? @injection.content "^[|>][%-+%d][%-+%d]")
  (#offset! @injection.content 0 3 0 0)
  (#set! injection.language "promql"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (flow_node
      (plain_scalar
        (string_scalar) @injection.content))
    (block_node
      (block_sequence
        (block_sequence_item
          (flow_node
            (plain_scalar
              (string_scalar) @injection.content)))))
  ]
  (#eq? @_key "expr")
  (#set! injection.language "promql"))

(block_mapping_pair
  key: (flow_node) @_key
  value: [
    (flow_node
      [
        (single_quote_scalar)
        (double_quote_scalar)
      ] @injection.content)
    (block_node
      (block_sequence
        (block_sequence_item
          (flow_node
            [
              (single_quote_scalar)
              (double_quote_scalar)
            ] @injection.content))))
  ]
  (#eq? @_key "expr")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "promql"))
