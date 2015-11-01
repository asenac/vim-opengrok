if exists("b:current_syntax")
    finish
endif

syn match ogModeComment "^\".*"
syn match ogModeLoc '[^:\"]\+:\(\d\+\)\? '

" Special cases
syn include @Cpp syntax/cpp.vim
unlet b:current_syntax
syn include @Java syntax/java.vim
unlet b:current_syntax
syn include @Python syntax/python.vim
unlet b:current_syntax
syn include @Make syntax/make.vim
unlet b:current_syntax
syn include @CMake syntax/cmake.vim
unlet b:current_syntax
syn include @Ant syntax/ant.vim
unlet b:current_syntax

syntax region ogModeCpp matchgroup=ogModeLoc keepend start=+^[^\"].*\.[ch]\(pp\)\?:\d* + end=+$+ contains=@Cpp
syntax region ogModeJava matchgroup=ogModeLoc keepend start=+^[^\"].*\.java:\d* + end=+$+ contains=@Java
syntax region ogModePython matchgroup=ogModeLoc keepend start=+^[^\"].*\.py:\d* + end=+$+ contains=@Python
syntax region ogModeMake matchgroup=ogModeLoc keepend start=+^[^\"].*\(GNU\)\?[Mm]akefile:\d* + end=+$+ contains=@Make
syntax region ogModeCMake0 matchgroup=ogModeLoc keepend start=+^[^\"].*\/CMakeLists.txt:\d* + end=+$+ contains=@CMake
syntax region ogModeCMake1 matchgroup=ogModeLoc keepend start=+^[^\"].*\.cmake:\d* + end=+$+ contains=@CMake
syntax region ogModeAnt matchgroup=ogModeLoc keepend start=+^[^\"].*\/build.xml:\d* + end=+$+ contains=@Ant

hi def link ogModeComment Comment
hi link ogModeLoc Identifier

let b:current_syntax = "opengrok"
