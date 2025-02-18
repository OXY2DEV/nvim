[
  "("
  ")"
  "["
  "]"
] @punctuation.bracket

[
  (escaped_character)
  (start_assertion)
  (end_assertion)
  (escape_sequence)
] @string.escape

[
  (zero_or_more)
  (one_or_more)
  (lazy)
  (optional)
] @operator

(character_set
  [
    "^" @operator
    (character_range
      "-" @operator)
  ])

(literal_character) @string

(character_set_content
  (literal_character) @constant.character)

