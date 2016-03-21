" autoload/memolist.vim
" Author:  Akira Maeda <glidenote@gmail.com>
" Version: 0.1.2
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

function! s:join_without_empty(string)
  return join(split(a:string, '\v\s+'), g:memolist_delimiter_yaml_array)
endfunction

" retun lines contain beween start pattern and end pattern.
" retun lines don't contain start pattern and end pattern.
function! s:getline_regexp_range(start_pattern, end_pattern)
  call cursor(1, 1)
  let start_line_number =  search(a:start_pattern, 'nc') + 1
  call cursor(start_line_number, 1)
  let end_line_number =  search(a:end_pattern, 'n') - 1
  return getline(start_line_number, end_line_number)
endfunction

function! s:get_yaml_front_matter()
  return s:getline_regexp_range(
        \ g:memolist_delimiter_yaml_start,
        \ g:memolist_delimiter_yaml_end)
endfunction

function! s:get_items_from_yaml_front_matter()
  let items = {}
  for line in s:get_yaml_front_matter()
    let item_name = matchstr(line, '\v^.+\ze:')
    let item_value = matchstr(line, '\v^.+:\s+\zs.+\ze$')
    if item_value[0] == '[' && item_value[-1:-1] == ']'
      let item_tmp = split(item_value[1:-2], g:memolist_delimiter_yaml_array)
      unlet item_value
      let item_value = item_tmp
    endif
    let items[item_name] = item_value
    unlet item_value
  endfor
  return items
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

if !exists('g:memolist_delimiter_yaml_array')
  let g:memolist_delimiter_yaml_array = " "
endif

if !exists('g:memolist_delimiter_yaml_start')
  let g:memolist_delimiter_yaml_array = "=========="
endif

if !exists('g:memolist_delimiter_yaml_end')
  let g:memolist_delimiter_yaml_array = "- - -"
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
  elseif !empty(get(g:, 'memolist_ex_cmd', ''))
    exe g:memolist_ex_cmd s:escarg(g:memolist_path)
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
  call memolist#new_with_meta(a:title, [], [])
endfunction

function! memolist#new_copying_meta(title, exclude_item_names)
  let items =  s:get_items_from_yaml_front_matter()
  if !empty(a:exclude_item_names)
    for item_name in split(a:exclude_item_names, '\s')
      if has_key(items, item_name)
        let items[item_name] = type(items[item_name]) == type([]) ? [] : ''
      end
    endfor
  endif
  call memolist#new_with_meta(a:title, join(items['tags'],
        \ g:memolist_delimiter_yaml_array), join(items['categories'],
        \ g:memolist_delimiter_yaml_array))
endfunction

function! memolist#new_with_meta(title, tags, categories)
  let items = {
  \ 'title': a:title,
  \ 'date':  localtime(),
  \ 'tags':  a:tags,
  \ 'categories': a:categories,
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

  if get(g:, 'memolist_prompt_tags', 0) != 0 && empty(items['tags'])
    let items['tags'] = s:join_without_empty(input("Memo tags: "))
  endif

  if get(g:, 'memolist_prompt_categories', 0) != 0 && empty(items['categories'])
    let items['categories'] = s:join_without_empty(input("Memo categories: "))
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
