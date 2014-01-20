"===========================================================================
" Script Title: vimcaps: never be bothered by the capslock again.
" Description:  Toggle off capslock when back to normal mode or gain focus,
"               as well as a "complete control" over the keyboard event.
"               (The 0.0.x version is windows only)
" Author:       LiTuX <suxpert AT gmail DOT com>
" Last Change:  2014-01-20 17:20:46
" Version:      0.0.2
"
" Install:      unpack all into your plugin folder, that's all.
"               If you are using "vundle" or "vim-addons-manager",
"               see README at "https://github.com/suxpert/vimcaps".
"
" Usage:        No further configuration is needed to use this plugin,
"               it will automatically handle your capslock:
"               when "InsertLeave", "BufferWinEnter" and "FocusGained",
"               "vimcaps" will toggle off it to prevent unwanted commands.
"
"               You can use the functions that vimcaps offered, to do
"               some cool stuff. As an example, see "vimcaps#dance()",
"               which flash the capslock LED for a while.
"               You can test it via ":call vimcaps#dance(5)",
"               then the capslock LED should flash for about 5 seconds.
"               Of course you can interrupt it by "Ctrl-C". Have fun!
"
" Changes:
"       0.0.2:  Optimize functions, add "vimcaps#dance()" for fun.
"               Add high level functions for numlock and scrollock.
"       0.0.1:  initial upload, windows only, ready to use.
"===========================================================================

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

function s:whichlock( name )
    if a:name =~ 'capslock'
        let which = 1
    elseif a:name =~ 'numlock'
        let which = 2
    elseif a:name =~ 'scrollock'
        let which = 4
    else    " no such lock
        let which = 0
    endif
    return which
endfunction

function s:lockstate( which )
    " return 1 if lock is on, 0 if off;
    let which = s:whichlock(a:which)
    if which == 0
        return -1
    endif
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
        let ret = libcallnr(s:vimcaps_lib, "LockToggled", which)
        let ret = and(ret, 1)
    elseif has("mac") || has("macunix")
        " for mac
        let ret = -1
    elseif has("unix")
        let ret = -1
    endif
    return ret
endfunction

function vimcaps#state()
    " return 1 if capslock is on, 0 if off;
    return s:lockstate('capslock')
endfunction

function vimcaps#number_state()
    " return 1 if numlock is on, 0 if off;
    return s:lockstate('numlock')
endfunction

function vimcaps#scroll_state()
    " return 1 if scrollock is on, 0 if off;
    return s:lockstate('scrollock')
endfunction

function s:togglelock( which )
    " send a `xxxlock press` keyevent to toggle the status.
    let which = s:whichlock(a:which)
    if which == 0
        return
    endif
    if has("win32") || has("win64") || has("win32unix")
        " for windows
        call libcallnr(s:vimcaps_lib, "ToggleLock", which)
    elseif has("mac") || has("macunix")
        " for mac
    elseif has("unix")
    endif
endfunction

function vimcaps#toggle()
    " send a `capslock press` keyevent to toggle the status.
    call s:togglelock('capslock')
endfunction

function vimcaps#toggle_number()
    " send a `numlock press` keyevent to toggle the status.
    call s:togglelock('numlock')
endfunction

function vimcaps#toggle_scroll()
    " send a `scrollock press` keyevent to toggle the status.
    call s:togglelock('scrollock')
endfunction

function vimcaps#toggleoff()
    if vimcaps#state() == 1
        silent call vimcaps#toggle()
    endif
endfunction

" An example of control the capslock, just for fun.
function vimcaps#dance( timeout )
    call vimcaps#toggleoff()
    try
        for time in range(a:timeout)
            sleep 100m
            silent call vimcaps#toggle()   " on
            sleep 200m
            silent call vimcaps#toggle()   " off
            sleep 100m
            silent call vimcaps#toggle()   " on
            sleep 200m
            silent call vimcaps#toggle()   " off
            sleep 400m
        endfor
    catch /^Vim:Interrupt$/
        echo "Interrupt"
    finally
        " clean up, turn off capslock
        call vimcaps#toggleoff()
    endtry
endfunction

" enable by default, if you don't want it be enabled, add
" :let g:vimcaps_loaded = 1
" to your vimrc, or just uninstall this plugin. :)
augroup vimcaps
    au!
    autocmd BufWinEnter,InsertLeave,FocusGained * call vimcaps#toggleoff()
augroup END

