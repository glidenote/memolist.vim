" autoload/memolist.vim
" Author:  Akira Maeda <glidenote@gmail.com>
" Version: 0.0.5
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

if !exists('g:memolist_template_path')
  let g:memolist_template_path = ""
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
  try
    if qfixgrep == 'true'
      exe "Vimgrep" s:escarg(word) s:escarg(g:memolist_path . "/*")
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
  exe (&l:modified ? "sp" : "e") s:escarg(g:memolist_path . "/" . file_name)

  " memo template
  if g:memolist_template_path == ""
    let template = s:default_template(title, date, tags, categories)
  else
    let path = expand(g:memolist_template_path, ":p")
    let path = path . "/" . g:memolist_memo_suffix . ".txt"
    if filereadable(path)
      let template = []
      let lines = readfile(path, 'b')
      for line in lines
        if line =~ "{{_title_}}"
          call add(template, substitute(line, "{{_title_}}", title, ""))
        elseif line =~ "{{_date_}}"
          if date == ""
            continue
          endif
          call add(template, substitute(line, "{{_date_}}", date, ""))
        elseif line =~ "{{_tags_}}"
          if tags == ""
            continue
          endif
          call add(template, substitute(line, "{{_tags_}}", tags, ""))
        elseif line =~ "{{_categories_}}"
          if categories == ""
            continue
          endif
          call add(template, substitute(line, "{{_categories_}}", categories, ""))
        else
          call add(template, line)
        endif
      endfor
    else
      let template = s:default_template(title, date, tags, categories)
    endif
  endif
  let err = append(0, template)

endfunction

function! s:default_template(title, date, tags, categories)
  let template = ["title: " . a:title , "=========="]
  if a:date != ""
    call add(template, "date: "  . a:date)
  endif
  if a:tags != ""
    call add(template, "tags: [" . tags . "]")
  endif
  if a:categories != ""
    call add(template, "categories: [" . a:categories . "]")
  endif
  call extend(template,["- - -"])

  return template
endfunction

let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
