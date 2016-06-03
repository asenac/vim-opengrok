if exists('loaded_opengrok') || &compatible
    finish
endif
let loaded_opengrok = 1

" Line continuation used here
let s:cpo_save = &cpo
set cpo&vim

command! -nargs=? -complete=customlist,opengrok#complete_search_mode
            \ OgSearch call opengrok#search_command(<q-args>, input('Text: ', expand("<cword>")))
command! -nargs=? -complete=customlist,opengrok#complete_search_mode
            \ OgSearchCWord call opengrok#search_command(<q-args>, expand("<cword>"))
command! -nargs=1 OgSearchFile call opengrok#search_command('p', <q-args>)
command! -nargs=1 -complete=dir OgIndex call opengrok#index_dir(<q-args>)
command! -nargs=0 OgReindex call opengrok#reindex()
command! -nargs=0 OgMode call opengrok#og_mode()

" restore 'cpo'
let &cpo = s:cpo_save
unlet s:cpo_save
