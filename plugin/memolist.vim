" memolist.vim  
" Maintainer:   Akira Maeda
"
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

"------------------------
" setting
"------------------------
if !exists('g:memolist_path')
  let g:memolist_path = $HOME . "/memo"
endif

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

function s:esctitle(str)
  let str = a:str
  let str = tolower(str)
  let str = substitute(str, g:memolist_title_pattern, '-', 'g')
  let str = substitute(str, '\(--\)\+', '-', 'g')
  let str = substitute(str, '\(^-\|-$\)', '', 'g')
  return str
endfunction

function! s:error(str)
  echohl ErrorMsg
  echomsg a:str
  echohl None
  let v:errmsg = a:str
endfunction

if !isdirectory(g:memolist_path)                                                                                                                           
  call mkdir(g:memolist_path, 'p')                                                                                                                         
endif

"------------------------
" function
"------------------------
function! s:BufInit(path)
  let b:memolist_root = a:path
  if !exists("g:autoloaded_memolist") && v:version >= 700
    runtime! autoload/memolist.vim
  endif
  " FIXME: This should be handled by the autocmd, but we don't set memolist_root
  " until after that autocmd is run, so it won't match.
  syn match Comment /\%^---\_.\{-}---$/ contains=@Spell
endfunction

function MemoList()
  exe "e " . g:memolist_path 
endfunction
command! -nargs=0 MemoList :call MemoList()

function MemoGrep(word)
  let word = a:word
  if word == ''
    let word = input("MemoGrep word: ")
  endif
  let qfixgrep = g:memolist_qfixgrep
  if qfixgrep != ''
    exe "Vimgrep " word . " " . g:memolist_path . "/*"
  else
    exe "vimgrep " word . " " . g:memolist_path . "/*"
  endif
endfunction
command! -nargs=? MemoGrep :call MemoGrep(<q-args>)

function MemoNew(title)
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
    let title = input("Memo title: ")
  endif
  if tags != ""
    let tags = input("Memo tags: ")
  endif
  if categories != ""
    let categories = input("Memo categories: ")
  endif
  if title != ''
    let file_name = strftime("%Y-%m-%d-") . s:esctitle(title) . "." . g:memolist_memo_suffix
    echo "Making that memo " . file_name
    exe "e " . g:memolist_path . "/" . file_name
    
    " memo template
    let template = ["# title: " . title ]
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
  else
    call s:error("You must specify a title")
  endif
endfunction
command! -nargs=? MemoNew :call MemoNew(<q-args>)

let &cpo = s:cpo_save

" vim:set ft=vim ts=2 sw=2 sts=2:
