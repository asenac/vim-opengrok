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
            let groups = matchlist(line, '\([^:]\+\):\(\d\+\)\? \[\(.*\)\]$')
            if len(groups) == 0
                continue
            endif
            let [path, lnum, text] = groups[1:3]

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
function! opengrok#og_mode_search(type) abort
    let modes = {
                \ 'f' : 'Full text',
                \ 'd' : 'Definition',
                \ 'r' : 'Symbol',
                \ 'p' : 'Path',
                \ }
    let text = get(modes, a:type)
    let pattern = input(text . ": ")
    if len(pattern) == 0
        call opengrok#show_error("Command cancelled")
        return
    endif
    let results = opengrok#search("-" . a:type, pattern)
    let lastline = line('$')
    setlocal modifiable
    let to_append = []
    for line in results
        let groups = matchlist(line, '\([^:]\+\):\(\d\+\)\? \(.*\)$')
        if len(groups) != 0
            let path = fnamemodify(groups[1], ":~:.")
            let line = path . ":" . groups[2] . " " . groups[3]
        else
            " Display as a commented line
            let line = '" ' . line
        endif
        call add(to_append, line)
    endfor
    call append(line('$'), to_append)
    call cursor(lastline + 1, 0)
    exec "normal! z\<cr>"
    setlocal nomodifiable
endfunction

function! opengrok#og_mode_jump() abort
    let line = getline('.')
    let groups = matchlist(line, '\([^:]\+\):\(\d\+\)\? \[\(.*\)\]$')
    if len(groups) == 0
        return
    endif
    let [path, lnum] = groups[1:2]
    exe "new " . path
    call cursor(lnum, 0)
endfunction

let s:og_mode_help_text = [
            \ '" Opengrok Mode',
            \ '" f: full text, d: definition, r: symbol, p: path',
            \ '" c: clear, h: help',
            \ ]

function! opengrok#og_mode_help() abort
    setlocal modifiable
    let lastline = line('$')
    call append(lastline, s:og_mode_help_text)
    call cursor(lastline + 1, 0)
    exec "normal! z\<cr>"
    setlocal nomodifiable
    call opengrok#og_mode_check_indexed()
endfunction

function! opengrok#og_mode_clear() abort
    setlocal modifiable
    normal! ggVGG"_d
    call append(0, s:og_mode_help_text)
    setlocal nomodifiable
    call opengrok#og_mode_check_indexed()
endfunction

function! s:set_mappings() abort
    nnoremap <buffer> <silent> f
                \ :call opengrok#og_mode_search('f')<CR>
    nnoremap <buffer> <silent> d
                \ :call opengrok#og_mode_search('d')<CR>
    nnoremap <buffer> <silent> r
                \ :call opengrok#og_mode_search('r')<CR>
    nnoremap <buffer> <silent> p
                \ :call opengrok#og_mode_search('p')<CR>
    nnoremap <buffer> <silent> c
                \ :call opengrok#og_mode_clear()<CR>
    nnoremap <buffer> <silent> h
                \ :call opengrok#og_mode_help()<CR>
    nnoremap <buffer><silent> <CR>
                \ :call opengrok#og_mode_jump()<CR>
endfunction

function! opengrok#og_mode_check_indexed()
    let root = opengrok#find_index_root_dir()
    if len(root) == 0
        call opengrok#show_error("Current directory not indexed")
    endif
endfunction

function! opengrok#og_mode()
    if &insertmode
        return
    endif

    enew

    setlocal
                \ buftype=nofile
                \ nocursorcolumn
                \ noswapfile

    call s:set_mappings()
    set filetype=opengrok
    call opengrok#og_mode_clear()
    setlocal nomodifiable nomodified
endfunction
