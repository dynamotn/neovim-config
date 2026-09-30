; A text block without a language tag is Markdown.
((text_block
  .
  (raw_text) @injection.content)
  (#set! injection.language "markdown"))

(text_block
  (language) @injection.language
  (raw_text) @injection.content)

; Short tags D2 accepts that name no parser of their own.
((text_block
  (language) @_language
  (raw_text) @injection.content)
  (#eq? @_language "md")
  (#set! injection.language "markdown"))

((text_block
  (language) @_language
  (raw_text) @injection.content)
  (#eq? @_language "js")
  (#set! injection.language "javascript"))

((text_block
  (language) @_language
  (raw_text) @injection.content)
  (#eq? @_language "ts")
  (#set! injection.language "typescript"))

([
  (line_comment)
  (block_comment)
] @injection.content
  (#set! injection.language "comment"))
