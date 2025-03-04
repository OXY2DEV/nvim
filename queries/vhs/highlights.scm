(output
  "Output" @keyword
  (destination) @string.special.path)

(require
  "Require" @keyword
  (dependency) @module)

(settings
  "Set" @keyword
  (settings_name) @property)

(type
  "Type" @keyword)

(type
  [
   "@"
   (duration)
   ] @attribute)

(key_command
  (key) @operator)

(key_command
  [
   "@"
   (duration)
   (number)
   ] @attribute)

(wait
  "Wait" @keyword)

(wait
  (scope) @attribute.builtin)

(wait
  (pattern) @string.regexp)

(wait
  [
   "@"
   (duration)
   ] @attribute)

(sleep
  "Sleep" @keyword)

(show) @keyword
(hide) @keyword

(screenshot
  "Screenshot" @keyword
  (destination) @string.special.path)

(copy
  "Copy" @keyword)

(paste) @keyword

(environment
  "Env" @keyword
  (variable) @variable.builtin)

(source
  "Source" @keyword
  (destination) @module)

(string) @string
(escaped_string) @string.escape
(number) @number
(boolean) @boolean
(percentage) @number
(json) @string.special
(literal) @constant
(duration) @number

(comment) @comment

