if exists('g:autoloaded_opengrok') || &compatible
  finish
endif
let g:autoloaded_opengrok = 1

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
        return []
    endif
    let params = ["-R " . root . "/" . g:opengrok_cfg,
                \ a:type, shellescape(a:pattern)]
    return opengrok#exec(g:opengrok_search_class, params)
endfunction

function! opengrok#search_and_populate_loclist(type, pattern) abort
    let lines = opengrok#search(a:type, a:pattern)
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
            let entry.filename = fnamemodify(path, ':.')
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
    call opengrok#search_and_populate_loclist("-" . type, a:pattern)
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

"
" opengrok-mode
"
function! opengrok#og_mode_search(type, pattern) abort
    let results = opengrok#search(a:type, a:pattern)
    normal GG
    setlocal modifiable
    call append(line('$'), results)
    setlocal nomodifiable
endfunction

function! opengrok#og_mode_jump() abort
    let line = getline('.')
    let cmp = matchlist(line, '\([^:]\+\):\(\d\+\)\? \[\(.*\)\]$')
    if len(cmp) == 0
        return
    endif
    let [path, lnum] = cmp[1:2]
    exe "new " . path
    call cursor(lnum, 0)
endfunction

function! s:set_mappings() abort
    nnoremap <buffer> <silent> f
                \ :call opengrok#og_mode_search('-f', input('Full text: '))<CR>
    nnoremap <buffer> <silent> d
                \ :call opengrok#og_mode_search('-d', input('Definition: '))<CR>
    nnoremap <buffer> <silent> r
                \ :call opengrok#og_mode_search('-r', input('Symbol: '))<CR>
    nnoremap <buffer> <silent> p
                \ :call opengrok#og_mode_search('-p', input('Path: '))<CR>
    nnoremap <buffer><silent> <CR>
                \ :call opengrok#og_mode_jump()<CR>
endfunction

function! opengrok#og_mode()
    if &insertmode
        return
    endif

    enew

    setlocal
                \ buftype=nofile
                \ nocursorcolumn
                \ nolist
                \ noswapfile

    setlocal nomodifiable nomodified
    call s:set_mappings()
    set filetype=opengrok
endfunction
