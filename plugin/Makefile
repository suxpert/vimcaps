# GNU make Makefile for vimcaps' library
# Copyright (C) 2014 LiTuX, all wrongs reserved.

TARGETNAME = keyboard
SRC = $(TARGETNAME).c

ifeq ($(OS), Windows_NT)
# For windows, on an x86 system it must be 32-bit;
# but an x86_64 system can run both 32-bit and 64-bit vim,
# what makes it more complex is that the compiler can be x86 or x64 too.
# I don't know how to detect which vim and compiler will be used,
# so provide two dlls in order that most users won't need to compile.
COMPILER = TCC
CFLAGS = -Wall -shared
LDFLAGS = -luser32
OUTPARAM = -o
ifeq ($(COMPILER), TCC)
TCC32 = /tcc32/tcc
TCC64 = /tcc64/tcc
else ifeq ($(COMPILER), GCC)
GCC32 = /mingw32/bin/gcc
GCC64 = /mingw64/bin/gcc
else ifeq ($(COMPILER), CLANG)
CLANG32 = /mingw32/bin/clang
CLANG64 = /mingw64/bin/clang
else ifeq ($(COMPILER), CL)
# Note for cl/VC user: cl depends on environment %lib% and %include%,
# thus only run cl may failed on compiling.
# This makefile is *not* NMAKE compatible.
CL32 = $(VCINSTALLDIR)\bin\cl
CL64 = $(VCINSTALLDIR)\bin\x86_amd64\cl
CFLAGS = /nologo /W4 /LD
LDFLAGS = /link user32.lib
OUTPARAM = /out
else
# what compiler are you using? Do It Yourself, :)
endif
TARGET32 = $(TARGETNAME)-x86.dll
TARGET64 = $(TARGETNAME)-x64.dll
TARGET: $(TARGET32) $(TARGET64)
$(TARGET32): $(SRC)
	$($(COMPILER)32) $(CFLAGS) $< $(LDFLAGS) $(OUTPARAM) $@
$(TARGET64): $(SRC)
	$($(COMPILER)64) $(CFLAGS) $< $(LDFLAGS) $(OUTPARAM) $@

else ifeq ($(shell uname), Linux)
# For linux, vimcaps now depends on X11,
# you'll need gcc, make, Xlib to compile this library.
TARGET = $(TARGETNAME).so
CC = gcc
CFLAGS = -Wall -shared -fPIC
LDFLAGS = -lX11
OUTPARAM = -o
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $< $(LDFLAGS) $(OUTPARAM) $@

else ifeq ($(shell uname), Darwin)
# For OS X, TODO
else
# NOT SUPPORTED YET
endif

