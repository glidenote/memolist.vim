" memolist.vim
" Maintainer:  Akira Maeda <glidenote@gmail.com>
" Version:  0.0.5
" See doc/memolist.txt for instructions and usage.

" Code {{{1
" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set

if (exists("g:loaded_memolist") && g:loaded_memolist) || &cp
  finish
endif
let g:loaded_memolist = 1

let s:cpo_save = &cpo
set cpo&vim

if !exists('g:memolist_path')
  let g:memolist_path = $HOME . "/memo"
endif

command! -nargs=0 MemoList :call memolist#list()
command! -nargs=? MemoGrep :call memolist#grep(<q-args>)
command! -nargs=? MemoNew :call memolist#new(<q-args>)

let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
