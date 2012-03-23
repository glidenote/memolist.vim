# memolist.vim

This is a vimscript for create and manage memo.
memolist is inspired by [jekyll.vim](https://github.com/csexton/jekyll.vim).

## Setup

Set the path to your memo directory in your .vimrc.(default directory `~/memo`)

    let g:memolist_path = "path/to/dir"

You may also want to add a few mappings to stream line the behavior:

    map <Leader>mn  :MemoNew<CR>
    map <Leader>ml  :MemoList<CR>
    map <Leader>mg  :MemoGrep<CR>

## options:

    let g:memolist_memo_suffix = "markdown"
    let g:memolist_memo_suffix = "txt"
    let g:memolist_memo_date = "%Y-%m-%d %H:%M"
    let g:memolist_memo_date = "epoch"
    let g:memolist_memo_date = "%D %T"
    let g:memolist_prompt_tags = "true"
    let g:memolist_prompt_categories = "true"

## Commands

Create New Memo:

    :MemoNew

Show Memo List:

    :MemoList

Grep Memo Directory:

    :MemoGrep

## Install

Copy it to your pugin directory.

## Requirements

 * [fuenor/qfixgrep](https://github.com/fuenor/qfixgrep)

## License

Lcense: Same terms as Vim itself (see [license](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license))
