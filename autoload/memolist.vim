" autoload/memolist.vim
" Author:  Akira Maeda <glidenote@gmail.com>
" Version: 0.0.4
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
  let g:memolist_title_pattern = "[ '\"]"
endif

if !exists('g:memolist_prompt_tags')
  let g:memolist_prompt_tags = ""
endif

if !exists('g:memolist_prompt_categories')
  let g:memolist_prompt_categories = ""
endif

if !exists('g:memolist_qfixgrep')
  let g:memolist_qfixgrep = ""
endif

if !exists('g:memolist_vimfiler')
  let g:memolist_vimfiler = ""
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
  return escape(a:s, ' ')
endfunction

let g:memolist_path = expand(g:memolist_path, ':p')
if !isdirectory(g:memolist_path)
  call mkdir(g:memolist_path, 'p')
endif

"------------------------
" function
"------------------------
function! memolist#list()
  let vimfiler = g:memolist_vimfiler
  if vimfiler == 'true'
    exe "VimFiler" s:escarg(g:memolist_path)
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
  let qfixgrep = g:memolist_qfixgrep
  if qfixgrep == 'true'
    exe "Vimgrep" s:escarg(word) s:escarg(g:memolist_path . "/*")
  else
    exe "vimgrep" s:escarg(word) s:escarg(g:memolist_path . "/*")
  endif
endfunction

function! memolist#_complete_ymdhms(...)
  return [strftime("%Y%m%d%H%M")]
endfunction

function! memolist#new(title)
  let date = g:memolist_memo_date
  let tags = g:memolist_prompt_tags
  let categories = g:memolist_prompt_categories

  if date == "epoch"
    let date = localtime()
  elseif date != ""
    let date = strftime(date)
  endif
  let title = a:title
  if title == ''
    let title = input("Memo title: ", "", "customlist,memolist#_complete_ymdhms")
  endif
  if title == ''
    return
  endif
  if tags != ""
    let tags = input("Memo tags: ")
  endif
  if categories != ""
    let categories = input("Memo categories: ")
  endif

  let file_name = strftime("%Y-%m-%d-") . s:esctitle(title) . "." . g:memolist_memo_suffix

  echo "Making that memo " . file_name
  exe "e" s:escarg(g:memolist_path . "/" . file_name)

  " memo template
  let template = ["title: " . title , "=========="]
  if date != ""
    call add(template, "date: "  . date)
  endif
  if tags != ""
    call add(template, "tags: [" . tags . "]")
  endif
  if categories != ""
    call add(template, "categories: [" . categories . "]")
  endif
  call extend(template,["- - -"])

  let err = append(0, template)

endfunction

let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
