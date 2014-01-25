# TODO LIST

This is vimcaps TODO list, you'll find what I'm going to do,
what I want to add, or something else with `vimcaps`.
You may offer help if you can. :)

## vimcaps Features
+ Toggle off the capslock when back to normal mode.
  The basic functions, get the capslock status, sent keyboard events.

    - [x] Windows support works.

    - [ ] Linux support:
        xWindow (libX11) under testing, If you can offer help,
        send me a pull request or even some tips.
        For commands: `xset` can get the status, but need X (libX11);
        `setleds` do not need X, but failed on my test.
        I'll try ioctl() later.

    - [ ] OS X support:
        I've found such APIs: `CGEventCreateKeyboardEvent`,
        `CGEventPost` et al.
        I don't have a Mac, so I can't test them.

+ Show keyboard status on statusline.
  If the get status function works, this feature can **partly** work.
  It should be in "real-time" when a lock is toggled, but now I have no
  idea to do that (How to send some commands to vim without 'KeyEvent' to
  refresh the statusline, from an extra library,
  if the vim is not a remote server?).

    - [ ] Windows support.
        As far as I know, windows dll CAN have event listener on the
        `capslock` KeyDown event (Yes, the lock is on as soon as
        the lock key is down, not up). But I don't know how to tell vim
        to refresh the statusline.

    - [ ] Linux support.
        An xWindow program can listen to the `capslock` KeyDown event,
        but I don't know if a shared library can do this or not.
        Also, the library still need to tell vim to refresh the statusline.

        For none-X applications (i.e. CLI on TTYs), it seems that ncurses
        do not have such event listener, but TTYs seems to have similar
        abilities (e.g. map capslock to others), so... perhaps vim can too?

    - [ ] OS X support.
        Don't know.

## Future
- So actually, if this function is not provided by an extra library, but
  vim itself, we won't need to *tell* vim to refresh the statusline anymore,
  vim will even have a new feature on `autocmd`, for example, do something
  with autocmd on a `KeyDown` event, on a `KeyUp` event, or even on a
  `MouseMove` event.... In order to do this, we need to patch vim:

    - [x] vim now have lots of features that are not cross platform,
        so NO reason for "this feature can't be cross platform";

    - [x] some of vim features are using different code (of course) on
        different platforms, so there is NO reason for
        "the code is not cross platform";

    - [x] no matter for Windows or xWindow, to support such a feature is NOT
        so hard (For windows, only few lines of code is needed, for example),
        so there's NO reason for "Wow, it seems too hard to implement".

Thus, the *next big* thing vimcaps should do, is to **patch** vim. :)

