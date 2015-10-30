if exists('g:syntax_opengrok') || &compatible
  finish
endif
let g:syntax_opengrok = 1

syn match ogModeComment "^\".*"
syn match ogModeNormalLine "^[^\"].*" contains=ogModeJump,ogModeContent
syn match ogModeJump '[^:\"]\+:\(\d\+\)\? '
syn match ogModeContent '\[.*\]$'

hi def link ogModeComment Comment
hi def link ogModeJump Identifier
hi def link ogModeContent Special
