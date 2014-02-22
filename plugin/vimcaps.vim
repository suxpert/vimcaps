"===========================================================================
" Script Title: vimcaps: never be bothered by the capslock again.
" Description:  Toggle off capslock when back to normal mode or gain focus,
"               as well as a "complete control" over the keyboard event.
"               (complete control is now windows only.)
" Author:       LiTuX <suxpert AT gmail DOT com>
" Last Change:  2014-02-22 16:07:02
" Version:      0.1.1
"
" Install:      unpack all into your plugin folder, that's all.
"               If you are using "vundle" or "vim-addons-manager",
"               see README at "https://github.com/suxpert/vimcaps".
"               For linux user, you'll need gcc and Xlib to compile
"               the library (manually or let vimcaps do it)
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
"       0.1.1:  Add option to disable the default autocmd,
"               move most codes to `autoload`.
"       0.1.0:  Add xWindow support, now vimcaps works on linux (under X).
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

if !exists("g:vimcaps_status_style")
    let g:vimcaps_status_style = "upper"
endif
if !exists("g:vimcaps_status_separator")
    let g:vimcaps_status_separator = " "
endif

" enable by default, if you don't want it be enabled, add
" :let g:vimcaps_disable_autocmd = 1
" to your vimrc, or uninstall this plugin. :)
if !exists('g:vimcaps_disable_autocmd') || g:vimcaps_disable_autocmd == 0
    augroup vimcaps
        au!
        autocmd BufWinEnter,InsertLeave,FocusGained * call vimcaps#capsoff()
    augroup END
endif

