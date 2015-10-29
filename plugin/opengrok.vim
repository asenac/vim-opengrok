"if exists('loaded_opengrok')
    "finish
"endif
"let loaded_opengrok=1

" Line continuation used here
let s:cpo_save = &cpo
set cpo&vim


let g:opengrok_index_dir = '.opengrok'
let g:opengrok_cfg = '.opengrok/configuration.xml'
let g:opengrok_jar = expand('~/local/opengrok-0.12.1/lib/opengrok.jar')
let g:opengrok_indexer_class = 'org.opensolaris.opengrok.index.Indexer'
let g:opengrok_search_class = 'org.opensolaris.opengrok.search.Search'
let g:opengrok_default_opts = '-Xmx2048m'

function! opengrok#show_error(msg)
    echohl ErrorMsg | echomsg "[vim-opengrok] " . a:msg | echohl None
endfunction

function! opengrok#find_index_root_dir()
    let dir = expand('%:p:h')
    while !filereadable(dir . '/' . g:opengrok_cfg)
        let ndir = fnamemodify(dir, ':p:h')
        if ndir == dir
            return ''
        endif
        let dir = ndir
    endwhile
    return dir
endfunction

function! opengrok#exec(class, params)
    let cmd = "java " . g:opengrok_default_opts .
                \ "-cp " . g:opengrok_jar .
                \ " " . a:class
    for param in params
        let cmd .= " " . param
    endfor
    return system(cmd)
endfunction

function! opengrok#search(type, pattern)
    let root = opengrok#find_index_root_dir()
    if len(root) == 0
        call opengron#show_error("Current directory not indexed")
    fi
    let params = ["-R " . root, type, pattern]
    let res = opengrok#exec(g:opengrok_search_class, params)
endfunction

function! opengrok#index_dir(dir)
endfunction


" restore 'cpo'
let &cpo = s:cpo_save
unlet s:cpo_save
