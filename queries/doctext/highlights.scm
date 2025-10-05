(word) @spell

(italic) @markup.italic
(bold) @markup.strong
(code) @markup.raw

(single_quote) @markup.link
(double_quote) @markup.quote

(issue_reference) @constant

(number) @number

(mention) @label
(url) @string.special.url
(autolink) @markup.link.url


[
  (punctuation)
  (start_delimiter)
  (end_delimiter)
  (injection_delimiter)
] @punctuation.delimiter

[
 ":"
 ","
] @punctuation.delimiter

[
 "("
 ")"
] @punctuation.bracket


type: (_) @type

(task_scope
  (word) @markup.strong)

(breaking) @operator

(_
  type: (word) @comment.note
  (#any-of? @comment.note "PRAISE" "praise" "SUGGESTION" "suggestion" "THOUGHT" "thought" "note" "NOTE" "info" "INFO" "XXX" "BREAKING CHANGE"))

(_
  type: (word) @comment.warning
  (#any-of? @comment.warning "NITPICK" "nitpick" "WARNING" "warning" "FIX" "fix" "HACK" "hack"))

(_
  type: (word) @comment.todo
  (#any-of? @comment.todo "TODO" "todo" "TYPO" "typo" "WIP" "wip"))

(_
  type: (word) @comment.error
  (#any-of? @comment.error "ISSUE" "issue" "ERROR" "error" "FIXME" "fixme" "DEPRECATED" "deprecated"))


(code_block
  language: (string) @label
  content: (code_block_content) @markup.raw)


(comment) @comment

(comment
  property: (string) @label)

(comment
  property: (string) @type
  content: (string) @string)

(comment
  content: (string) @string.special.url
  (#match? @string.special.url "[/\\\\]$"))

(comment
  content: (string) @string.special.url
  (#match? @string.special.url "\\.\\w+$"))

(comment
  property: (string) @constant
  (#any-of? @constant "date" "Date" "Date modified")
  content: (string) @string.special)

