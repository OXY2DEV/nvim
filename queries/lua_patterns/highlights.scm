(escape_sequence) @character.special

(literal_character) @character

(character_class) @variable.builtin

(escaped_character) @string.escape

(any_character) @variable.member

(character_reference) @constant.builtin

[
 (start_assertion)
 (end_assertion)
] @keyword


[
 (zero_or_more)
 (one_or_more)
 (optional)

 (lazy)
] @keyword.operator

[
  "("
  ")"
  "["
  "]"
] @punctuation.bracket

(character_set
  [
    "^" @operator
    (character_range
      "-" @operator)
  ])

