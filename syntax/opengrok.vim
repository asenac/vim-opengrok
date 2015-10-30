if exists("b:current_syntax")
    finish
endif

syn match ogModeComment "^\".*"
syn match ogModeNormalLine "^[^\"].*" contains=ogModeJump,ogModeContent
syn match ogModeJump '[^:\"]\+:\(\d\+\)\? '
syn match ogModeContent '\[.*\]$' contains=ogModeBold
syn match ogModeBold '<b>.*</b>'

hi def link ogModeComment Comment
hi def link ogModeJump Identifier
hi def link ogModeContent Comment
hi def link ogModeBold Special
