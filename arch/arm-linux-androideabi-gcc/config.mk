NDK_PLATFORM=android-16
CPU = armv7-a

ifeq ("$(strip $(shell command -v ndk-which))","")
$(error No 'ndk-which' found in PATH. Is Android NDK installed correctly?)
endif


NDK_ROOT=$(shell dirname $(shell command -v ndk-which))
NDK_SYSROOT=$(NDK_ROOT)/platforms/$(NDK_PLATFORM)/arch-arm

#ccpath = $(shell dirname $(shell ndk-which gcc)) 
#PATH := "$(shell dirname $(shell ndk-which gcc))":$(PATH)

#AS      = $(shell ndk-which as)
CC      = $(shell ndk-which gcc) --sysroot=$(NDK_SYSROOT) -march=$(CPU)
CPP     = $(shell ndk-which cpp) --sysroot=$(NDK_SYSROOT) 
CXX     = $(shell ndk-which g++) --sysroot=$(NDK_SYSROOT) -march=$(CPU)
LD      = $(shell ndk-which ld)  --sysroot=$(NDK_SYSROOT)
AR      = $(shell ndk-which ar)
NM      = $(shell ndk-which nm)
STRIP   = $(shell ndk-which strip)
OBJCOPY = $(shell ndk-which objcopy)
OBJDUMP = $(shell ndk-which objdump)


host    = arm-linux-androideabi
prefix  = /usr
packdir = platforms/$(NDK_PLATFORM)/arch-arm
sysroot = $(NDK_SYSROOT)

