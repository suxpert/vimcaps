"===========================================================================
" Script Title: vimcaps: never be bothered by the capslock again.
" Description:  Toggle off capslock when back to normal mode or gain focus,
"               as well as a "complete control" over the keyboard event.
"               (The 0.0.x version is windows only)
" Author:       LiTuX <suxpert AT gmail DOT com>
" Last Change:  2014-02-15 16:12:17
" Version:      0.0.3
"
" Install:      unpack all into your plugin folder, that's all.
"               If you are using "vundle" or "vim-addons-manager",
"               see README at "https://github.com/suxpert/vimcaps".
"
" Usage:        No further configuration is needed to use this plugin,
"               it will automatically handle your capslock:
"               when "InsertLeave", "BufferWinEnter" and "FocusGained",
"               "vimcaps" will toggle it off to prevent unwanted commands.
"
"               Starting from 0.0.3, vimcaps provide a function for
"               statusline: vimcaps#statusline(), which allows to display
"               the keyboard lock status in your statusline.
"
"               You'll need to add this to your "statusline" to enable it:
"                   set stl=...%{vimcaps#statusline(N)}...
"               where N is a mask, can be a combination of:
"                   1 for capslock; 2 for numlock; 4 for scrollock;
"               if N is negative, space is added when lock is off;
"
"               It checks "g:vimcaps_status_style" for the name style,
"               which can be (default is upper)
"                   'upper': "CAPS", "NUM", "SCRL"
"                   'lower': "caps", "num", "scrl"
"                   'short': "C", "N", "S"
"               and "g:vimcaps_status_separator" for the separator.
"               For example, vimcaps#statusline(-3) by default will return
"               "     NUM" if capslock is off and number lock is on, or
"               "CAPS NUM" if both of them are toggled, or even
"               "        " if both are off.
"
"               You can also use the functions that vimcaps offered, to do
"               some cool stuff. As an example, see "vimcaps#dance()",
"               which flash the capslock LED for a while.
"               You can test it via ":call vimcaps#dance(5)",
"               then the capslock LED should flash for about 5 seconds.
"               Of course you can interrupt it by "Ctrl-C". Have fun!
"
" Changes:
"       0.0.3:  Add "vimcaps#statusline()" function for showing the
"               keyboard lock status in statusline.
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
let s:vimcaps_src = s:vimcaps_path."/".s:vimcaps_libname.".c"
if has("win32")
    let s:vimcaps_lib = s:vimcaps_path."\\".s:vimcaps_libname."-x86.dll"
elseif has("win64")
    let s:vimcaps_lib = s:vimcaps_path."\\".s:vimcaps_libname."-x64.dll"
elseif has("win32unix")
    " win32unix can be x86 (msys1, msys2/x86) or x64 (msys2/x64)...
    " Since I have no better way to determine which platform we are in,
    " We'll use try blocks for that.
    try
        let s:vimcaps_lib = s:vimcaps_path."/".s:vimcaps_libname."-x86.dll"
        silent call libcallnr(s:vimcaps_lib, "LibReady", 0)
    catch                   " /^Vim\%((\a\+)\)\=:E364/
        let s:vimcaps_lib = s:vimcaps_path."/".s:vimcaps_libname."-x64.dll"
    endtry
elseif has("mac") || has("macunix")
    " vimcaps now do not support mac, sorry. (It can be done AFAIK).
    finish
elseif has("unix")
    " Linux support is under testing.
    let s:vimcaps_lib = s:vimcaps_path."/".s:vimcaps_libname.".so"
    if getftime(s:vimcaps_lib) < getftime(s:vimcaps_src)
        silent !cd s:vimcaps_path && make
    endif
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

let libstatus = -1
try
    silent let libstatus = libcallnr(s:vimcaps_lib, "LibReady", 0)
catch /^Vim\%((\a\+)\)\=:E364/
    echohl WarningMsg
    echo "Can not call library function, vimcaps can not load!"
    echohl None
    finish
finally
    if libstatus != 1
        echohl WarningMsg
        echo "Library Error, vimcaps can not load!"
        echohl None
        finish
    endif
endtry

function s:whichlock( name )
    if a:name == 1 || a:name =~ 'capslock'
        let which = 1
    elseif a:name == 2 || a:name =~ 'numlock'
        let which = 2
    elseif a:name == 4 || a:name =~ 'scrollock'
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
        let ret = libcallnr(s:vimcaps_lib, "LockToggled", which)
    elseif has("mac") || has("macunix")
        " for mac
        let ret = -1
    elseif has("unix")
        let ret = libcallnr(s:vimcaps_lib, "LockToggled", which)
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

function s:toggleon( which )
    let which = s:whichlock(a:which)
    if which == 0
        return
    endif
    call libcallnr(s:vimcaps_lib, "ToggleOn", which)
endfunction

function s:toggleoff( which )
    let which = s:whichlock(a:which)
    if which == 0
        return
    endif
    call libcallnr(s:vimcaps_lib, "ToggleOff", which)
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

function vimcaps#capson()
    silent call s:toggleon('capslock')
endfunction
function vimcaps#capsoff()
    silent call s:toggleoff('capslock')
endfunction

function vimcaps#numon()
    silent call s:toggleon('numlock')
endfunction
function vimcaps#numoff()
    silent call s:toggleoff('numlock')
endfunction

function vimcaps#scrlon()
    if has("win32") || has("win64") || has("win32unix")
        " for windows
        silent call s:toggleon('scrollock')
    elseif has("mac") || has("macunix")
        " for mac
    elseif has("unix")
        silent call libcallnr(s:vimcaps_lib, "xNamedIndicatorOn", "Scroll Lock")
    endif
endfunction
function vimcaps#scrloff()
    if has("win32") || has("win64") || has("win32unix")
        " for windows
        silent call s:toggleoff('scrollock')
    elseif has("mac") || has("macunix")
        " for mac
    elseif has("unix")
        silent call libcallnr(s:vimcaps_lib, "xNamedIndicatorOff", "Scroll Lock")
    endif
endfunction

" An example of control the capslock, just for fun.
function vimcaps#dance( timeout )
    call vimcaps#capsoff()
    call vimcaps#srcloff()
    try
        for time in range(a:timeout)
            sleep 100m
            silent call vimcaps#capson()    " on
            silent call vimcaps#scrlon()    " on
            sleep 200m
            silent call vimcaps#capsoff()   " off
            silent call vimcaps#scrloff()   " off
            sleep 100m
            silent call vimcaps#capson()    " on
            silent call vimcaps#scrlon()    " on
            sleep 200m
            silent call vimcaps#capsoff()   " off
            silent call vimcaps#scrloff()   " off
            sleep 400m
        endfor
    catch /^Vim:Interrupt$/
        echo "Interrupt"
    finally
        " clean up, turn off capslock
        call vimcaps#capsoff()
        call vimcaps#scrloff()
    endtry
endfunction

if !exists("g:vimcaps_status_style")
    let g:vimcaps_status_style = "upper"
endif
if !exists("g:vimcaps_status_separator")
    let g:vimcaps_status_separator = " "
endif

" TODO: vimcaps#statusline() now can NOT update until statusline redraws.
" It ought to force a update whenever one of the locks is toggled.
function! vimcaps#statusline(N)
    let names = {}
    let names["upper"] = [["    ","CAPS"], ["   ","NUM"], ["    ","SCRL"]]
    let names["lower"] = [["    ","caps"], ["   ","num"], ["    ","scrl"]]
    let names["short"] = [[" ", "C"], [" ", "N"], [" ", "S"]]
    let sep = g:vimcaps_status_separator
    if a:N < 0
        let fixed = 1
        let which = -a:N
    else
        let fixed = 0
        let which = a:N
    endif
    if has_key(names, g:vimcaps_status_style)
        let style = g:vimcaps_status_style
    else
        let style = "upper"
    endif

    let result = ""
    let locks = [1, 2, 4]               " capslock, numlock, scrollock
    for i in range(3)
        if and(which, locks[i])
            let state = s:lockstate(locks[i])
            let this_state = (fixed||state)? names[style][i][state] : ""
            let result .= len(result)&&len(this_state) ? sep : ""   " TODO
            let result .= this_state
        endif
    endfor
    return result
endfunction

" enable by default, if you don't want it be enabled, add
" :let g:vimcaps_loaded = 1
" to your vimrc, or just uninstall this plugin. :)
augroup vimcaps
    au!
    autocmd BufWinEnter,InsertLeave,FocusGained * call vimcaps#capsoff()
augroup END

