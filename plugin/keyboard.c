/* keyboard.c: Keyboard event for vimcaps
 * Copyright (C) 2010-2014 LiTuX, all wrongs reserved.
 *
 * Last Change: 2014-01-21 20:31:26
 *
 * This file is part of vimcaps, most of the code came from my libmkbd
 * To compile this file, you need a compiler such as gcc, cl, or even tcc.
 * For WinSDK/VC user: open a cmd with environment setting (vcvars), then
 *  \> cl /nologo /W4 /LD <thisfile> /link user32.lib /out keyboard-xXX.dll
 * For MinGW/MSYS user: open a cmd with environment or login to bash, then
 *  $ gcc -Wall -shared <thisfile> -l user32.lib -o keyboard-xXX.dll
 * If you're using TinyCC, the command is almost the same as for gcc.
 * */

#define WINVER 0x0502
#define _WIN32_WINNT 0x0502
#define NOCOMM
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#define DLL_EXPORT __declspec(dllexport)

/* TinyCC and old MinGW do not define this */
#ifndef MAPVK_VK_TO_VSC
#   define MAPVK_VK_TO_VSC 0
#endif

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

DLL_EXPORT
int LockToggled( int lock )
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
    return GetState( vKey );    // return (int) GetKeyState( vKey );
}

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

