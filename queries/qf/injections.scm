(code_block
  (language_delimiter) @_lang
  (content) @injection.content
  (#set-qf-lang! @_lang))

; Uncomment the lines below if you want syntax highlighting
; for the default quickfix list.
;
; ((code_block
;   .
;   (content) @injection.content
;   .) @_qf
;   (#qf-fallback-lang! @_qf))
