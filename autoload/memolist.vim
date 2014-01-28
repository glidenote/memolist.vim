" autoload/memolist.vim
" Author:  Akira Maeda <glidenote@gmail.com>
" Version: 0.1.0
" Install this file as autoload/memolist.vim.  This file is sourced manually by
" plugin/memolist.vim.  It is in autoload directory to allow for future usage of
" Vim 7's autoload feature.

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set

if &cp || exists("g:autoloaded_memolist")
  finish
endif
let g:autoloaded_memolist= '1'

let s:cpo_save = &cpo
set cpo&vim

" Utility Functions {{{1
function! s:error(str)
  echohl ErrorMsg
  echomsg a:str
  echohl None
  let v:errmsg = a:str
endfunction
" }}}1

"------------------------
" setting
"------------------------
if !exists('g:memolist_memo_suffix')
  let g:memolist_memo_suffix = "markdown"
endif

if !exists('g:memolist_memo_date')
  let g:memolist_memo_date = "%Y-%m-%d %H:%M"
endif

if !exists('g:memolist_title_pattern')
  let g:memolist_title_pattern = "[ /\\'\"]"
endif

if !exists('g:memolist_template_dir_path')
  let g:memolist_template_dir_path = ""
endif

if !exists('g:memolist_vimfiler_option')
  let g:memolist_vimfiler_option = "-split -winwidth=50"
endif

if !exists('g:memolist_unite_source')
  let g:memolist_unite_source = "file"
endif

if !exists('g:memolist_unite_option')
  let g:memolist_unite_option = ""
endif

function! s:esctitle(str)
  let str = a:str
  let str = tolower(str)
  let str = substitute(str, g:memolist_title_pattern, '-', 'g')
  let str = substitute(str, '\(--\)\+', '-', 'g')
  let str = substitute(str, '\(^-\|-$\)', '', 'g')
  return str
endfunction

function! s:escarg(s)
  return escape(substitute(a:s, '\\', '/', 'g'), ' ')
endfunction

let g:memolist_path = expand(g:memolist_path, ':p')
if !isdirectory(g:memolist_path)
  call mkdir(g:memolist_path, 'p')
endif

"------------------------
" function
"------------------------
function! memolist#list()
  if get(g:, 'memolist_vimfiler', 0) != 0
    exe "VimFiler" g:memolist_vimfiler_option s:escarg(g:memolist_path)
  elseif get(g:, 'memolist_unite', 0) != 0
    exe "Unite" g:memolist_unite_source.':'.s:escarg(g:memolist_path) g:memolist_unite_option
  else
    exe "e" s:escarg(g:memolist_path)
  endif
endfunction

function! memolist#grep(word)
  let word = a:word
  if word == ''
    let word = input("MemoGrep word: ")
  endif
  if word == ''
    return
  endif

  try
    if get(g:, 'memolist_qfixgrep', 0) != 0
      exe "Vimgrep -r" s:escarg(word) s:escarg(g:memolist_path . "/*")
    else
      exe "vimgrep" s:escarg(word) s:escarg(g:memolist_path . "/*")
    endif
  catch
    redraw | echohl ErrorMsg | echo v:exception | echohl None
  endtry
endfunction

function! memolist#_complete_ymdhms(...)
  return [strftime("%Y%m%d%H%M")]
endfunction

function! memolist#new(title)
  let items = {
  \ 'title': a:title,
  \ 'date':  localtime(),
  \ 'tags':  [],
  \ 'categories':  [],
  \}

  if g:memolist_memo_date != 'epoch'
    let items['date'] = strftime(g:memolist_memo_date)
  endif
  if items['title'] == ''
    let items['title']= input("Memo title: ", "", "customlist,memolist#_complete_ymdhms")
  endif
  if items['title'] == ''
    return
  endif

  if get(g:, 'memolist_prompt_tags', 0) != 0
    let items['tags'] = join(split(input("Memo tags: "), '\s'), ' ')
  endif

  if get(g:, 'memolist_prompt_categories', 0) != 0
    let items['categories'] = join(split(input("Memo categories: "), '\s'), ' ')
  endif

  if get(g:, 'memolist_filename_prefix_none', 0) != 0
    let file_name = s:esctitle(items['title'])
  else
    let file_name = strftime("%Y-%m-%d-") . s:esctitle(items['title'])
  endif
  if stridx(items['title'], '.') == -1
    let file_name = file_name . "." . g:memolist_memo_suffix
  endif

  echo "Making that memo " . file_name
  exe (&l:modified ? "sp" : "e") s:escarg(g:memolist_path . "/" . file_name)

  " memo template
  let template = s:default_template
  if g:memolist_template_dir_path != ""
    let path = expand(g:memolist_template_dir_path, ":p")
    let path = path . "/" . g:memolist_memo_suffix . ".txt"
    if filereadable(path)
      let template = readfile(path)
    endif
  endif
  " apply template
  let old_undolevels = &undolevels
  set undolevels=-1
  call append(0, s:apply_template(template, items))
  let &undolevels = old_undolevels
  set nomodified

endfunction

let s:default_template = [
\ 'title: {{_title_}}',
\ '==========',
\ 'date: {{_date_}}',
\ 'tags: [{{_tags_}}]',
\ 'categories: [{{_categories_}}]',
\ '- - -',
\]

function! s:apply_template(template, items)
  let mx = '{{_\(\w\+\)_}}'
  return map(copy(a:template), "
  \  substitute(v:val, mx,
  \   '\\=has_key(a:items, submatch(1)) ? a:items[submatch(1)] : submatch(0)', 'g')
  \")
endfunction

let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
