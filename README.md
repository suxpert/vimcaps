vimcaps
=======

Never be bothered by caps lock

As is known, `capslock` is almost useless in vim's normal mode.
If it happens that the capslock is locked, you know what the fuck
is going to happen:
+   You want to move up, but came out a `man`;
+   You wanna move down, but line joins;
+   You try to undo those joins, but it undo itself;
+   ...

So, lots of vimmers disabled the capslock or map it to another key.
Yes, that is a beautiful solution. I don't like capslock too.
But someday, I notice that the capslock is still useful,
---if you have to use an on screen keyboard (e.g., with a touch screen)
Then I decide to do a simple thing instead of remap the keyboard:
Toggle off the capslock when back to normal mode,
---that is what this plugin do.

`vimcaps` now support Windows and Linux (actually xWindow, we need Xlib),
TTYs are still not supported.
BSD hasn't been tested, suggestions are welcomed.
Since I don't have a mac, there *won't* be any mac support until someone
send a pull request. :)

You may consider to [rate this plugin](http://www.vim.org/scripts/script.php?script_id=4834)
if you think it is useful, or just feels like it. Thanks!

## Install
It is highly recommended to use an addon manager for vim plugins.

The most convenient way to install this plugin is use `vundle` or
`vim-addon-manager`, or some similar plugin-manager.

For vundle user, add the following line into your `vimrc`:
```vim
Bundle 'suxpert/vimcaps'
```
If you use `vam`, you may active this plugin by the name `vimcaps`,
it will download this plugin from vim.org.
To use the up-to-date version here, add `github:suxpert/vimcaps` to your
`ActivateAddons` list, or add
```vim
call vam#ActivateAddons('github:suxpert/vimcaps')
```
to your `vimrc`.

For Linux user, you need to compile the library manually, or let vimcaps
compile it automatically. make, gcc, Xlib must be installed first.
Linux support **may** have some bug (Although according to my test,
only with such a strange way can vimcaps work.
I'm using ubuntu 13.10 and a logitech small keyboard and onboard BTW).
What we need to know is that, xWindow have a `shift lock` modifier.
I don't know if such a lock exists on a physical keyboard or not,
but Xlib functions can't change onboard's shift lock.
So this shift lock is still a problem.

## Usage
After install, this plugin will automatically handle the capslock
for you:
`vimcaps` register autocmd for toggle off the capslock when
`InsertLeave`, `BufferWinEnter` and `FocusGained`.
Note that FocusGained *may* don't work if you are under a terminal.

Starting from 0.0.3, `vimcaps` provide a function `vimcaps#statusline()`
in order to display the keyboard locks status on the statusline.
You'll need to add it to your statusline settings to enable it.
```vim
set stl=...%{vimcaps#statusline(N)}...
```
Here `N` is a mask, can be a combination of:
+ 1 for capslock;
+ 2 for numlock;
+ 4 for scrollock;

If N is negative, the result will have a fixed width. For example.
`vimcaps#statusline(-3)` by default will return
```
"     NUM" if capslock is off and number lock is on, or
"CAPS NUM" if both of them are toggled, or even
"        " if both are off.
```

The display style and separator is controled by `g:vimcaps_status_style`
and `g:vimcaps_status_separator`. Three build-in styles are:
```
'upper': show as "CAPS", "NUM", "SCRL" (default)
'lower': show as "caps", "num", "scrl"
'short': show as "C", "N", "S"
```

If you are using `powerline` or `airline`, read the manual about how to
modify its statusline.

`vimcaps#statusline()` now can **NOT** update until statusline redraws.
Though it ought to force a update whenever one of the locks is toggled.
If you know how to do this (for example, how to send a command or
whatever to vim whenever a `xxLock KeyDown` event happens without the
`--remote-send` commands), **Please help me to improve this plugin**.

If you have some better suggestions, **please tell me**, perhaps it
will be the default setting in a next version. :)

If you don't want `vimcaps` change your keyboard state,
add `let g:vimcaps_disable_autocmd = 1` to your vimrc,
or uninstall this plugin.

## Finally
Actually, to support `capslock` status should be quite easy, almost all
editors support this, but `vim` don't! So I have to write this plugin.
With the help of some input APIs, I made it work under windows
(and x window, Linux TTY and Mac OS X is not yet supported).
But, there are still issues for this
method: currently I can't deal with a `capslock` toggle in normal mode,
which I think should at least give a warning,
but I have no way to do that right now.
See [TODO](TODO.md) for details.

I wish, perhaps someday, this function will be integrated within vim,
and this plugin become useless then.
Will that happen? Let Bram know! :)

