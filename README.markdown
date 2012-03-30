# memolist.vim

This is a vimscript for create and manage memo.  
memolist.vim is inspired by [jekyll.vim](https://github.com/csexton/jekyll.vim).

## Setup

Set the path to your memo directory in your .vimrc.(default directory `$HOME/memo`)

    let g:memolist_path = "path/to/dir"

You may also want to add a few mappings to stream line the behavior:

    map <Leader>mn  :MemoNew<CR>
    map <Leader>ml  :MemoList<CR>
    map <Leader>mg  :MemoGrep<CR>

## Options

    let g:memolist_memo_suffix = "markdown"
    let g:memolist_memo_suffix = "txt"
    let g:memolist_memo_date = "%Y-%m-%d %H:%M"
    let g:memolist_memo_date = "epoch"
    let g:memolist_memo_date = "%D %T"
    let g:memolist_prompt_tags = 1
    let g:memolist_prompt_categories = 1
    let g:memolist_qfixgrep = 1
    let g:memolist_vimfiler = 1
    let g:memolist_template_dir_path = "path/to/dir"

## Commands

Create New Memo:

    :MemoNew

Show Memo List:

    :MemoList

Grep Memo Directory:

    :MemoGrep

## Install

Copy it to your plugin and autoload directory.

## License

Lcense: Same terms as Vim itself (see [license](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license))
