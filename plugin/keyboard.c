/* keyboard.c: Keyboard event for vimcaps
 * Copyright (C) 2010-2014 LiTuX, all wrongs reserved.
 *
 * Last Change: 2014-02-15 16:45:01
 *
 * This file is part of vimcaps, a layer for `calling` APIs with libcall.
 * The library provides some low-level functions similar to system APIs
 * which can be called in vim using libcallnr(), to read and modify the
 * state of the keyboard.
 *
 * I'm trying to find some APIs similar to Win32API SendInput/keybd_event
 * under linux, but failed so far (HELP!):
 * /dev/input/eventX needs permission,
 * ioctl on /dev/console needs permission,
 * letleds needs TTY, or root permission under X (/dev/tty7, for example).
 * xset needs X, and failed to turn on/off my capslock and numlock.
 * (Wait! Why my capslock led is on but capslock status is off??
 * Who designed this strange "feature"?? Why the man page and header file
 * are different? Why are the documents so useless? \cdots)
 * Finally I find the following methods works for me (I don't know if it
 * works everywhere or not) under X, thus in this version,
 * I'll use this ugly way, to make it at least work first.
 *
 * See Makefile for how to compile it.
 * */

/* FIXME: Too many #if-else */
#ifdef _WIN32
/************************** For windows ****************************/
#define WINVER 0x0502
#define _WIN32_WINNT 0x0502
#define NOCOMM
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

/* TinyCC and old MinGW do not define this */
#ifndef MAPVK_VK_TO_VSC
#   define MAPVK_VK_TO_VSC 0
#endif

#elif __APPLE__
/************************** For Mac OS ****************************/
#   error "Mac is not supported yet."

#elif __linux__
/*************************** For linux ****************************/
#include <X11/XKBlib.h>
Display *display = NULL;

#else
/* TODO: BSD support? */
#   error "Platform not supported."
#endif

#ifdef _WIN32
#   define DLL_EXPORT __declspec(dllexport)
#else
#   define DLL_EXPORT
#endif

#ifdef _WIN32
DLL_EXPORT
int GetState( int vKey )
{
    /* GetKeyState return SHORT, force to signed by two steps of cast.
     *
     * The return value specifies the status of the specified virtual key
     *  If the high-order bit is 1, the key is down; otherwise, it is up.
     *  If the low-order bit is 1, the key is toggled.
     *  A key, such as the CAPS LOCK key, is toggled if it is turned on.
     *  The key is off and untoggled if the low-order bit is 0.
     *  A toggle key's indicator light (if any) on the keyboard
     *  will be on when the key is toggled,
     *  and off when the key is untoggled.              --- MSDN
     * */
    signed short ret;
    ret = GetKeyState(vKey);
    return (int) ret;
}

static
int KiEvent( int vKey, DWORD dwFlags )
{
    INPUT in = {INPUT_KEYBOARD};
    in.ki.wVk = vKey;
    in.ki.wScan = MapVirtualKey(vKey, MAPVK_VK_TO_VSC);
    in.ki.dwFlags = dwFlags;
    in.ki.time = 0;                             // let the system manage
    in.ki.dwExtraInfo = 0;                      // No extra info.
    return SendInput(1, &in, sizeof(INPUT));    // 1 if success
}

DLL_EXPORT
int Press( int vKey )
{
    return KiEvent(vKey, 0);
}

DLL_EXPORT
int PressExt( int vKey )
{
    return KiEvent(vKey, KEYEVENTF_EXTENDEDKEY);
}

DLL_EXPORT
int Release( int vKey )
{
    return KiEvent(vKey, KEYEVENTF_KEYUP);
}

DLL_EXPORT
int ReleaseExt( int vKey )
{
    return KiEvent(vKey, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP);
}

DLL_EXPORT
int SendKey( int vKey )
{
    int ret;
    ret = Press(vKey);
    Sleep(10);
    ret += Release(vKey);
    return ret;                                 // 2 if all success
}

DLL_EXPORT
int SendKeyExt( int vKey )
{
    int ret;
    ret = PressExt(vKey);
    Sleep(10);
    ret += ReleaseExt(vKey);
    return ret;                                 // 2 if all success
}

DLL_EXPORT
int ToggleLock( int lock )
{
    /* lock can be:
     *  1 for capslock;
     *  2 for numlock;
     *  4 for scrollock;
     * */
    int vKey = 0;
    switch (lock) {
        case 1: // caps
            vKey = VK_CAPITAL;
            break;
        case 2: // num
            vKey = VK_NUMLOCK;
            break;
        case 4: // scroll
            vKey = VK_SCROLL;
            break;
        default: // do nothing
            break;
    }
    return SendKey( vKey );
}

DLL_EXPORT
BOOL WINAPI DllMain(HINSTANCE hModule, DWORD dwReason, LPVOID lpvReserved)
{
    /* Do nothing */
    switch (dwReason) {
        case DLL_PROCESS_ATTACH:
        case DLL_PROCESS_DETACH:
        case DLL_THREAD_ATTACH:
        case DLL_THREAD_DETACH:
            break;
        default:
            break;
    }
    return TRUE;
}
#elif __APPLE__
/* TODO */
#elif __linux__

void xkbd_init(void) __attribute__((constructor));
void xkbd_fini(void) __attribute__((destructor));

void xkbd_init(void)
{
    /* open connection with the server */
    display = XOpenDisplay(NULL);
    if (display == NULL) {
        /* TODO: what should I do on error? */
    }
}

void xkbd_fini(void)
{
    /* close connection to server */
    if (NULL != display) {
        XCloseDisplay(display);
    }
}

int xMaskedState( unsigned mask )
{
    int state = 0;
    XkbGetIndicatorState(display, XkbUseCoreKbd, &state);
    return state & mask;
}

int xAtom(const char * const name)
{
    return XInternAtom(display, name, 0)
}

int xGetState(unsigned atom)
{
    Bool state = 0;
    XkbGetNamedIndicator(display, atom, NULL, &state, NULL, NULL);
    return state;
}

int xGetNamedState(const char * const name)
{
    Bool state = 0;
    Atom atom = XInternAtom(display, name, 0);
    XkbGetNamedIndicator(display, atom, NULL, &state, NULL, NULL);
    return state;
}

static
int xSetIndicator(unsigned atom, Bool state)
{
    /* FIXME: This function don't work under my system */
    return XkbSetNamedIndicator(display, atom, True, state, False, NULL);
}

int xIndicatorOn(unsigned atom)
{
    return xSetIndicator(atom, 1);
}

int xIndicatorOff(unsigned atom)
{
    return xSetIndicator(atom, 0);
}

int xNamedIndicatorOn(const char * const name)
{
    return xSetIndicator(XInternAtom(display, name, 0), 1);
}

int xNamedIndicatorOff(const char * const name)
{
    return xSetIndicator(XInternAtom(display, name, 0), 0);
}

static
int xModifierMask(int lock)
{
    int mask;
    switch (lock) {
        case 1: // caps lock
            mask = 0x02;
            break;
        case 2: // num lock
            mask = 0x10;
            break;
        default:
            mask = 0;
    }
    return mask;
}

int xLockModifier(unsigned mask)
{
    /* This one works on my system, but can only modify caps/num lock.
     * where caps lock is 0x02(2) and num lock is 0x10(16):
     * TODO: linux man page info here;
     * But I don't know which is scroll lock. :(
     * */
    return XkbLockModifiers(display, XkbUseCoreKbd, mask, mask);
}

int xUnlockModifier(unsigned mask)
{
    return XkbLockModifiers(display, XkbUseCoreKbd, mask, 0);
}

#else
#endif

/* "High level" interfaces */
DLL_EXPORT
int LibReady( void )
{
#ifdef __linux__
    return NULL == display? 0: 1;
#else
    return 1;
#endif
}

DLL_EXPORT
int LockToggled( int lock )
{
    /* lock can be:
     *  1 for capslock;
     *  2 for numlock;
     *  4 for scrollock;
     * */
    int result;
#ifdef _WIN32
    int vKey = 0;
    switch (lock) {
        case 1: // caps
            vKey = VK_CAPITAL;
            break;
        case 2: // num
            vKey = VK_NUMLOCK;
            break;
        case 4: // scroll
            vKey = VK_SCROLL;
            break;
        default: // do nothing
            break;
    }
    result = 1 & (int) GetState( vKey );
#elif __APPLE__
#elif __linux__
    Atom which;
    switch (lock) {
        case 1:
            which = XInternAtom(display, "Caps Lock", 0);
            break;
        case 2:
            which = XInternAtom(display, "Num Lock", 0);
            break;
        case 4:
            which = XInternAtom(display, "Scroll Lock", 0);
            break;
        default:
            /* illegal */
            which  = 0;
    }
    result = xGetState(which);
#endif
    return result;
}

DLL_EXPORT
int ToggleOn( int lock )
{
    int result;
    if ( !LockToggled(lock) ) {
#ifdef _WIN32
        result = ToggleLock(lock);
#elif __APPLE__
#elif __linux__
        result = xLockModifier( xModifierMask(lock) );
#else
#endif
    }
    return result;
}

DLL_EXPORT
int ToggleOff( int lock )
{
    int result;
    if ( LockToggled(lock) ) {
#ifdef _WIN32
        result = ToggleLock(lock);
#elif __APPLE__
#elif __linux__
        result = xUnlockModifier( xModifierMask(lock) );
#else
#endif
    }
    return result;
}

