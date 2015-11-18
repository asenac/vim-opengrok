if exists("b:current_syntax")
    finish
endif

syn match ogmComment "^\".*"
syn match ogmPath contained '^\f\+'
syn match ogmInfo contained '|\(\d\+ col \d\+\)\?| '

let s:opengrok_use_embedded_syntax =
            \ get(g:, "opengrok_use_embedded_syntax", 0)

if s:opengrok_use_embedded_syntax
    syn match ogmLoc '^\f\+|\(\d\+ col \d\+\)\?| ' contains=ogmPath,ogmInfo

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
        exe "syntax region ogm".s." keepend "
                    \."start=+^\\f*".r."|\\(\\d\\+ col \\d\\+\\)| + "
                    \."end=+$+ contains=ogmLoc,@".s
    endfor
else
    syn match ogmAmp contained "&amp;" conceal cchar=&
    syn match ogmGt contained "&gt;" conceal cchar=>
    syn match ogmLt contained "&lt;" conceal cchar=<

    syn match ogmMatch contained "[^<]\+"
    syn region ogmBoldMatch contained concealends matchgroup=ogmBm start="<b>" end="</b>" contains=ogmMatch
    syn match ogmLoc '^\f\+|\(\d\+ col \d\+\)\?| .*$' contains=ogmPath,ogmInfo,ogmBoldMatch,ogmAmp,ogmGt,ogmLt

    hi def link ogmMatch Special
endif

hi def link ogmComment Comment
hi def link ogmPath Identifier
hi def link ogmInfo Comment

let b:current_syntax = "opengrok"
