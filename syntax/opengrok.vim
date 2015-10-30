if exists("b:current_syntax")
    finish
endif

syn match ogModeComment "^\".*"
syn match ogModeNormalLine "^[^\"].*" contains=ogModeJump,ogModeContent
syn match ogModeJump '[^:\"]\+:\(\d\+\)\? '
syn match ogModeContent '\[.*\]$'

hi def link ogModeComment Comment
hi def link ogModeJump Identifier
hi def link ogModeContent Special
