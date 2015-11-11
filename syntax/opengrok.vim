if exists("b:current_syntax")
    finish
endif

syn match ogModeComment "^\".*"

syn match ogModePath '^\f\+'
syn match ogModeInfo '|\(\d\+ col \d\+\)\?| '
syn match ogModeLoc '^\f\+|\(\d\+ col \d\+\)\?| ' contains=OgModePath,ogModeInfo

let embedded_syntax = [
            \ ["cpp",        "\\.[ch]\\(pp\\|xx\\)\\?"],
            \ ["java",       "\\.java"],
            \ ["javascript", "\\.js"],
            \ ["python",     "\\.py"],
            \ ["perl",       "\\.pl"],
            \ ["sh",         "\\.sh"],
            \ ["cmake",      "\\(\\.cmake\\|CMakeLists.txt\\)"],
            \ ["make",       "[Mm]akefile"],
            \ ["ant",        "build.xml"],
            \]

for [s, r] in embedded_syntax
    exec "syn include @".s." syntax/".s.".vim"
    unlet b:current_syntax
    exe "syntax region ogMode".s." keepend "
                \."start=+^\\f*".r."|\\(\\d\\+ col \\d\\+\\)| + "
                \."end=+$+ contains=ogModeLoc,@".s
endfor

hi def link ogModeComment Comment
hi link ogModePath Identifier
hi link ogModeInfo Comment

let b:current_syntax = "opengrok"
