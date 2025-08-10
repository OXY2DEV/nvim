; Highlighting for Neovim.
; Use a higher priority to override semantic highlights.

;;; Inline elements.

((word) @spell)

(italic) @markup.italic
(bold) @markup.strong
((code) @markup.raw @nospell
  (#set! priority 150))

((single_quote) @markup.link
  (#set! priority 150))
((double_quote) @markup.quote @nospell
  (#set! priority 150))

((issue_reference) @constant @nospell
  (#set! priority 150))

((number) @number
  (#set! priority 150))
; (punctuation) @punctuation.delimiter

((mention) @label
  (#set! priority 150))
(url) @string.special.url @nospell


;; Task specific highlights

(task
  (label) @markup.strong)

(task
  (decorations
    (topic) @markup.strong))

(task
  (label) @comment.note @nospell
  (#any-of? @comment.note "PRAISE" "praise" "SUGGESTION" "suggestion" "THOUGHT" "thought" "note" "NOTE" "info" "INFO" "XXX")
  (#set! priority 150))

(task
  (label) @comment.warning @nospell
  (#any-of? @comment.warning "NITPICK" "nitpick" "WARNING" "warning" "FIX" "fix" "HACK" "hack")
  (#set! priority 150))

(task
  (label) @comment.todo @nospell
  (#any-of? @comment.todo "TODO" "todo" "TYPO" "typo" "WIP" "wip")
  (#set! priority 150))

(task
  (label) @comment.error @nospell
  (#any-of? @comment.error "ISSUE" "issue" "ERROR" "error" "FIXME" "fixme" "DEPRECATED" "deprecated")
  (#set! priority 150))

(task
  (label)
  (decorations
    (topic) @markup.strong
    (#set! priority 150)))

((task)
 (paragraph) @comment)


;; Code block

(code_block
  "```" @punctuation.delimiter
  (language) @markup.raw)
