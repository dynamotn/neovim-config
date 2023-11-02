(container_key) @string.special
(shape_key) @variable
(attr_key) @property
(reserved) @error
(class_name) @constant

[
  (keyword_style)
  (keyword_classes)
  (keyword_class)
] @keyword

(keyword_underscore) @keyword.return
(string) @string
(container_key (string (string_fragment) @string))
(shape_key (string (string_fragment) @string))
(escape_sequence) @string.escape
(label) @text.title
(attr_value) @string
(integer) @number
(float) @float
(boolean) @boolean
[
  (language)
  (line_comment)
  (block_comment)
] @comment
(arrow) @operator ; label
[
  "["
  "]"
  "{"
  "}"
  "|"
] @punctuation.bracket
[ ";" (dot) ] @punctuation.delimiter
