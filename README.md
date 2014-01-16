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

`vimcaps` now only support Windows, Linux support will be added later.
Since I don't have a mac, there *won't* be any mac support until someone
send a pull request. :)

## Install
It is highly recommended to use an addon manager for vim plugins.

The most convenient way to install this plugin is use `vundle` or
`vim-addon-manager`, or some similar plugin-manager.

For vundle user, add the following line into your `vimrc`:
```vim
Bundle 'suxpert/vimcaps'
```
If you use `vam`, add `github:suxpert/vimcaps` to your
`ActivateAddons` list, or add
```vim
call vam#ActivateAddons('github:suxpert/vimcaps')
```
to your `vimrc`.

## Usage
After install, this plugin will automatically handle the capslock
for you:
`vimcaps` register autocmd for toggle off the capslock when
`InsertLeave`, `BufferWinEnter` and `FocusGained`.
Note that FocusGained *may* don't work if you are under a terminal.

If you have some better suggestions, **please tell me**, perhaps it
will be the default setting in a next version. :)

If you don't want that happen, add `let g:vimcaps_loaded = 1` to your
vimrc, or uninstall this plugin; If you think you need some of the functions
this plugin offered, and do NOT need it to control your capslock,
you may modify the script file, and please **tell me** that, thanks!

## Finally
Actually, to support `capslock` status should be quite easy, almost all
editors support this, but `vim` don't! So I have to write this plugin.
With the help of some input APIs, I made it work under windows (and will
work under Linux or even Mac OS). But, there are still issues for this
method: currently I can't deal with a `capslock` toggle in normal mode,
which I think should at least give a warning,
but I have no way to do that right now.

I wish, perhaps someday, this function will be integrated within vim,
and this plugin become useless then.
Will that happen? Let Bram know! :)

