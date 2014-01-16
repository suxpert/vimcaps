" vimcaps: never be bothered by the capslock again. :)
" Toggle off capslock when back to normal mode or gain focus.
"
" Copyright (C) 2014 LiTuX, all wrongs reserved.

if exists("g:vimcaps_loaded")
    finish
endif
let g:vimcaps_loaded = 1

let s:vimcaps_path = expand("<sfile>:p:h")
let s:vimcaps_libname = "keyboard"
if has("win32")
    let s:vimcaps_lib = s:vimcaps_path."\\".s:vimcaps_libname."-x86.dll"
elseif has("win64")
    let s:vimcaps_lib = s:vimcaps_path."\\".s:vimcaps_libname."-x64.dll"
elseif has("win32unix")
    " win32unix can be x86 (msys1, msys2/x86) or x64 (msys2/x64)...
    " Since I have no better way to determine which plantform we are in,
    " We'll use try blocks for that.
    try
        let s:vimcaps_lib = s:vimcaps_path."/".s:vimcaps_libname."-x86.dll"
        silent call libcallnr(s:vimcaps_lib, "LockToggled", 1)
    catch                   " /^Vim\%((\a\+)\)\=:E364/
        let s:vimcaps_lib = s:vimcaps_path."/".s:vimcaps_libname."-x64.dll"
    endtry
elseif has("mac") || has("macunix")
    " vimcaps now do not support mac, sorry. (It can be done AFAIK).
    finish
elseif has("unix")
    " Linux support is under testing.
    " let s:vimcaps_lib = s:vimcaps_path.s:vimcaps_libname.".so"
    finish
else
    " vimcaps now do not support your platform, sorry.
    finish
endif

if !filereadable(s:vimcaps_lib)
    echohl WarningMsg
    echo "vimcaps won't work without the library!"
    echohl None
    finish
endif

try
    silent call libcallnr(s:vimcaps_lib, "LockToggled", 1)
catch /^Vim\%((\a\+)\)\=:E364/
    echohl WarningMsg
    echo "Can not call library function, vimcaps can not load!"
    echohl None
    finish
endtry

function vimcaps#state()
    " return 1 if capslock is on, 0 if off;
    if has("win32") || has("win64") || has("win32unix")
        " for windows
        " The return value specifies the status of the specified virtual key
        "  If the high-order bit is 1, the key is down; otherwise, it is up.
        "  If the low-order bit is 1, the key is toggled.
        "  A key, such as the CAPS LOCK key, is toggled if it is turned on.
        "  The key is off and untoggled if the low-order bit is 0.
        "  A toggle key's indicator light (if any) on the keyboard
        "  will be on when the key is toggled,
        "  and off when the key is untoggled.              --- MSDN
        let ret = libcallnr(s:vimcaps_lib, "LockToggled", 1)
        let ret = and(ret, 1)
    elseif has("mac") || has("macunix")
        " for mac
        let ret = -1
    elseif has("unix")
        let ret = -1
    endif
    return ret
endfunction

function vimcaps#toggle()
    " send a `capslock press` keyevent to toggle the status.
    if has("win32") || has("win64") || has("win32unix")
        " for windows
        call libcallnr(s:vimcaps_lib, "ToggleLock", 1)
    elseif has("mac") || has("macunix")
        " for mac
    elseif has("unix")
    endif
endfunction

function vimcaps#toggleoff()
    if vimcaps#state() == 1
        silent call vimcaps#toggle()
    endif
endfunction

" enable by default, if you don't want it be enabled, add
" :let g:vimcaps_loaded = 1
" to your vimrc, or just uninstall this plugin. :)
augroup vimcaps
    au!
    autocmd BufWinEnter,InsertLeave,FocusGained * call vimcaps#toggleoff()
augroup END

