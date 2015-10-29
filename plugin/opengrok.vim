"if exists('loaded_opengrok')
    "finish
"endif
"let loaded_opengrok=1

" Line continuation used here
let s:cpo_save = &cpo
set cpo&vim

let g:opengrok_index_dir = '.opengrok'
let g:opengrok_cfg = '.opengrok/configuration.xml'
let g:opengrok_jar = '~/local/opengrok-0.12.1/lib/opengrok.jar'
let g:opengrok_indexer_class = 'org.opensolaris.opengrok.index.Indexer'
let g:opengrok_search_class = 'org.opensolaris.opengrok.search.Search'
let g:opengrok_default_opts = '-Xmx2048m'
let s:opengrok_allowed_opts = [ "d", "r", "p", "h", "f", "t"]

function! opengrok#show_error(msg)
    echohl ErrorMsg
    echomsg "[vim-opengrok] " . a:msg
    echohl None
endfunction

function! opengrok#find_index_root_dir()
    let dir = expand('%:p:h')
    while !filereadable(dir . '/' . g:opengrok_cfg)
        let ndir = fnamemodify(dir, ':h')
        if ndir == dir
            return ''
        endif
        let dir = ndir
    endwhile
    return dir
endfunction

function! opengrok#exec(class, params) abort
    let cmd = "java " . g:opengrok_default_opts .
                \ " -cp " . g:opengrok_jar .
                \ " " . a:class
    for param in a:params
        let cmd .= " " . param
    endfor
    " Note: As opengrok does not have a non-interactive mode
    " we will display only the first page of results
    return systemlist(cmd, "n")
endfunction

function! opengrok#search(type, pattern) abort
    let root = opengrok#find_index_root_dir()
    if len(root) == 0
        call opengrok#show_error("Current directory not indexed")
        return
    endif
    let params = ["-R " . root . "/" . g:opengrok_cfg,
                \ a:type, shellescape(a:pattern)]
    let lines = opengrok#exec(g:opengrok_search_class, params)
    if len(lines) == 1
        call opengrok#show_error(lines[0])
    else
        let locations = []
        for line in lines
            let cmp = matchlist(line, '\([^:]\+\):\(\d\+\)\? \[\(.*\)\]$')
            if len(cmp) == 0
                continue
            endif
            let [path, lnum, text] = cmp[1:3]

            let entry = {}
            let entry.filename = substitute(path, getcwd().'/', '', 'g')
            let entry.filepath = path
            let entry.lnum = lnum
            let entry.text = text

            call add(locations, entry)
        endfor

        call setloclist(winnr(), locations)
        if len(locations) > 0
            lopen
        endif
    endif
endfunction

function! opengrok#search_command(type, pattern) abort
    let type = a:type
    if len(type) == 0
        let type = "f"
    endif
    if index(s:opengrok_allowed_opts, type) == -1
        call opengrok#show_error("Invalid mode '" . type .
                    \ "'. Use one of the following: " .
                    \ join(s:opengrok_allowed_opts, ', '))
        return
    endif
    call opengrok#search("-" . type, a:pattern)
endfunction

function! opengrok#index_dir(dir)
    call opengrok#show_error("Not implemented yet!")
endfunction

function! opengrok#reindex()
    let root = opengrok#find_index_root_dir()
    if len(root) == 0
        call opengrok#show_error("Current directory not indexed")
        return
    endif
    call opengrok#show_error("Not implemented yet!")
endfunction

command! -nargs=? OgSearch call opengrok#search_command(<q-args>, input('Text: ', expand("<cword>")))
command! -nargs=0 OgSearchCWord call opengrok#search_command('f', expand("<cword>"))
command! -nargs=1 OgSearchFile call opengrok#search_command('p', <q-args>)
command! -nargs=1 -complete=dir OgIndex call opengrok#index_dir(<q-args>)
command! -nargs=0 OgReindex call opengrok#reindex()

" restore 'cpo'
let &cpo = s:cpo_save
unlet s:cpo_save
