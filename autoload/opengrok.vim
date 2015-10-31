if exists('g:autoloaded_opengrok') || &compatible
  finish
endif
let g:autoloaded_opengrok = 1

" Internal options
let s:opengrok_index_dir = '.opengrok'
let s:opengrok_cfg = '.opengrok/configuration.xml'
let s:opengrok_indexer_class = 'org.opensolaris.opengrok.index.Indexer'
let g:opengrok_search_class = 'org.opensolaris.opengrok.search.Search'
let s:opengrok_allowed_opts = [ "d", "r", "p", "h", "f", "t"]
let s:opengrok_latest_version =
            \ 'http://java.net/projects/opengrok/downloads/download/opengrok-0.12.1.tar.gz'

" Configuration options
if !exists('g:opengrok_default_options')
    let g:opengrok_default_options = '-Xmx2048m'
endif

function! s:check_opengrok_jar()
    if !exists('g:opengrok_jar')
        call s:show_error("g:opengrok_jar is not defined!")
        return 0
    elseif !filereadable(fnamemodify(g:opengrok_jar, ':p'))
        call s:show_error(g:opengrok_jar . " does not exist!")
        return 0
    endif
    return 1
endfunction

function! s:show_error(msg)
    echohl ErrorMsg
    echomsg "[vim-opengrok] " . a:msg
    echohl None
endfunction

function! opengrok#find_index_root_dir()
    let dir = expand('%:p:h')
    while !filereadable(dir . '/' . s:opengrok_cfg)
        let ndir = fnamemodify(dir, ':h')
        if ndir == dir
            return ''
        endif
        let dir = ndir
    endwhile
    return dir
endfunction

function! opengrok#exec(class, params) abort
    let cmd = "java " . g:opengrok_default_options .
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
        call s:show_error("Current directory not indexed")
        return []
    endif
    let params = ["-R " . root . "/" . s:opengrok_cfg,
                \ a:type, shellescape(a:pattern)]
    return opengrok#exec(g:opengrok_search_class, params)
endfunction

function! opengrok#search_and_populate_loclist(type, pattern) abort
    let lines = opengrok#search(a:type, a:pattern)
    if len(lines) == 1
        call s:show_error(lines[0])
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
    if !s:check_opengrok_jar()
        return
    endif
    let type = a:type
    if len(type) == 0
        let type = "f"
    endif
    if index(s:opengrok_allowed_opts, type) == -1
        call s:show_error("Invalid mode '" . type .
                    \ "'. Use one of the following: " .
                    \ join(s:opengrok_allowed_opts, ', '))
        return
    endif
    call opengrok#search_and_populate_loclist("-" . type, a:pattern)
endfunction

function! opengrok#index_dir(dir)
    if !s:check_opengrok_jar()
        return
    endif
    call s:show_error("Not implemented yet!")
endfunction

function! opengrok#reindex()
    if !s:check_opengrok_jar()
        return
    endif
    let root = opengrok#find_index_root_dir()
    if len(root) == 0
        call s:show_error("Current directory not indexed")
        return
    endif
    call s:show_error("Not implemented yet!")
endfunction

"
" opengrok-mode
"
function! opengrok#og_mode_search(type) abort
    if !s:check_opengrok_jar() || !s:check_indexed()
        return
    endif
    let modes = {
                \ 'f' : 'Full text',
                \ 'd' : 'Definition',
                \ 'r' : 'Symbol',
                \ 'p' : 'Path',
                \ }
    let text = get(modes, a:type)
    let pattern = input(text . ": ")
    if len(pattern) == 0
        call s:show_error("Command cancelled")
        return
    endif
    let results = opengrok#search("-" . a:type, pattern)
    if len(results) == 0
        return
    endif
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

function! opengrok#og_mode_jump(mode) abort
    let line = getline('.')
    let groups = matchlist(line, '\([^:]\+\):\(\d\+\)\? \[\(.*\)\]$')
    if len(groups) == 0
        return
    endif
    let [path, lnum] = groups[1:2]
    if a:mode == 'n'
        " open in a new window
        exe "new " . path
    elseif a:mode == 'o'
        " open in another window
        if winnr('$') == 1
            exe "new " . path
        else
            " the path might be relative to the current directory
            let cwd = getcwd()
            exe "wincmd p"
            exec "cd " . cwd
            exe "edit " . path
        endif
    else
        " open in a current window
        exe "edit " . path
    endif
    call cursor(lnum, 0)
endfunction

let s:og_mode_help_text = [
            \ '" f: full text, d: definition, r: symbol, p: path',
            \ '" c: clear, h: help',
            \ '" n: open in new window, t: open in this window',
            \ '" <cr>,o: open in another window',
            \ '',
            \ ]

function! s:help() abort
    let lastline = line('$')
    call append(lastline, s:og_mode_help_text)
    let root = opengrok#find_index_root_dir()
    if len(root) == 0
        let root = "No Index!"
    endif
    let headers = [
                \ '" Opengrok Mode',
                \ '" Indexed directory: ' . root,
                \ '" Working directory: ' . getcwd(),
                \ ]
    call append(lastline, headers)
    call cursor(lastline + 1, 0)
    exec "normal! z\<cr>"
    call s:check_indexed()
endfunction

function! opengrok#og_mode_help() abort
    setlocal modifiable
    call s:help()
    setlocal nomodifiable
endfunction

function! opengrok#og_mode_clear() abort
    setlocal modifiable
    normal! ggVGG"_d
    call s:help()
    exe "1d"
    setlocal nomodifiable
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
    nnoremap <buffer><silent> n
                \ :call opengrok#og_mode_jump('n')<CR>
    nnoremap <buffer><silent> o
                \ :call opengrok#og_mode_jump('o')<CR>

    " default action
    nnoremap <buffer><silent> <CR>
                \ :call opengrok#og_mode_jump('o')<CR>
    nnoremap <buffer><silent> <2-LeftMouse>
                \ :call opengrok#og_mode_jump('o')<CR>
endfunction

function! s:check_indexed()
    let root = opengrok#find_index_root_dir()
    if len(root) == 0
        call s:show_error("Current directory not indexed")
        return 0
    endif
    return 1
endfunction

let s:og_mode_buf_name = '[OpenGrok]'

function! opengrok#og_mode()
    if &insertmode || !s:check_opengrok_jar()
        return
    endif

    execute "silent keepjumps hide edit" . s:og_mode_buf_name
    setlocal
                \ buftype=nofile
                \ nocursorcolumn
                \ noswapfile

    call s:set_mappings()
    set filetype=opengrok
    call opengrok#og_mode_clear()
    setlocal nomodifiable nomodified
    let s:og_mode_running = 1
endfunction
