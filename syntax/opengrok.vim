if exists("b:current_syntax")
    finish
endif

syn match ogModeComment "^\".*"
syn match ogModeLoc '^\f\+|\(\d\+ col \d\+\)\?| '

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
    exe "syntax region ogMode".s." matchgroup=ogModeLoc keepend "
                \."start=+^\\f*".r."|\\(\\d\\+ col \\d\\+\\)| + "
                \."end=+$+ contains=@".s
endfor

hi def link ogModeComment Comment
hi link ogModeLoc Identifier

let b:current_syntax = "opengrok"
