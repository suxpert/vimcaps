"===========================================================================
" Script Title: vimcaps: never be bothered by the capslock again.
" Description:  Toggle off capslock when back to normal mode or gain focus,
"               as well as a "complete control" over the keyboard event.
"               (complete control is now windows only.)
" Author:       LiTuX <suxpert AT gmail DOT com>
" Last Change:  2014-02-22 16:07:08
" Version:      0.1.1
"===========================================================================

let s:vimcaps_undertty = 0

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
    " Linux support: x window MIGHT works.
    let s:vimcaps_lib = s:vimcaps_path."/".s:vimcaps_libname.".so"
    if getftime(s:vimcaps_lib) < getftime(s:vimcaps_src)
        silent exe "!cd ".s:vimcaps_path." && make"
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

let s:libstatus = -1
try
    silent let s:libstatus = libcallnr(s:vimcaps_lib, "LibReady", 0)
catch /^Vim\%((\a\+)\)\=:E364/
    echohl WarningMsg
    echo "Can not call library function, vimcaps can not load!"
    echohl None
    finish
finally
    if s:libstatus == 1
        " ready to use.
    elseif s:libstatus == 0
        " Seems that we are under TTY, TODO
        let s:vimcaps_tty = system("ps -s |awk '/ps/{print $2}'")
        if s:vimcaps_tty =~ 'tty\d'
            " silent exe '!setleds -L</dev/'.s:vimcaps_tty
            " setleds failed in my test: TTY have a keyboard state itself?
            let s:vimcaps_undertty = 1
        endif
        echohl WarningMsg
        echo "TTY is not yet supported"
        echohl None
        finish
    else
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
        if s:vimcaps_undertty == 0
            let ret = libcallnr(s:vimcaps_lib, "LockToggled", which)
        else
            " TODO
        endif
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

" TODO: This function is now windows only.
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

" these keyevent based functions are windows only.
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


" Some `high level` functions.
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
    call vimcaps#scrloff()
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

