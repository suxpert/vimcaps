" vimcaps: never be bothered by the capslock again. :)
" Toggle off capslock when back to normal mode.
"
" Copyright (C) 2014 LiTuX, all wrongs reserved.


if exists("g:vimcaps_loaded")
    finish
endif
let g:vimcaps_loaded = 1

function vimcaps#querystatus()
    " return 1 if capslock is on, 0 if off;
    return 1
endfunction

function vimcaps#sendkeys()
    " send a `capslock press` keyevent to toggle the status.
endfunction

function vimcaps#toggleoff()
    if vimcaps#querystatus() == 1
        call vimcaps#sendkeys()
    endif
    echo "Toggle off"
endfunction

" enable by default, if you don't want it be enabled, add
" :let g:vimcaps_loaded = 1
" to your vimrc, or just uninstall this plugin. :)
augroup vimcaps
    au!
    autocmd BufWinEnter,InsertLeave * call vimcaps#toggleoff()
augroup END

