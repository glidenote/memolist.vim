" autoload/memolist.vim
" Author:   Akira Maeda

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
" Commands {{{1

let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
