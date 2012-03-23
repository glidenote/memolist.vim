# memolist.vim

this is a vimscript for create and select memo.

## Setup

Set the path to your memo directory. default directory `~/memo`

    let g:memolist_path = "path/to/dir"

You may also want to add a few mappings to stream line the behavior:

    map <Leader>ml  :memolistList<CR>
    map <Leader>mn  :memolistNew<CR>

## options:

    let g:memolist_memo_suffix = "markdown"     # filetype
    let g:memolist_memo_date = "%Y-%m-%d %H:%M" # date format
    let g:memolist_prompt_tags = "true"         # tag (default:false)
    let g:memolist_prompt_categories = "true"   # category (default:false)

## Commands

Create New memo:

    :MemoNew

Show Memo List:

    :MemoList

## Install

Copy it to your pugin directory.

## License

Lcense: Same terms as Vim itself (see [license](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license))
