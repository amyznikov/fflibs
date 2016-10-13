# Make variables (CC, etc...)

host      		= aarch64-rpi3-linux-gnueabi

CROSS_COMPILE	= $(host)-
CROSS_ROOT		= /mnt/sdb1/x-tools/aarch64-rpi3-linux-gnueabi
PATH 			:= $(CROSS_ROOT)/bin:$(PATH)

#AS        = $(CROSS_COMPILE)as
CC        = $(CROSS_COMPILE)gcc
CXX       = $(CROSS_COMPILE)g++
CPP       = $(CC) -E
LD        = $(CROSS_COMPILE)ld
LDXX      = $(CXX)
AR        = $(CROSS_COMPILE)ar
#NM        = $(CROSS_COMPILE)nm
STRIP     = $(CROSS_COMPILE)strip
OBJCOPY   = $(CROSS_COMPILE)objcopy
OBJDUMP   = $(CROSS_COMPILE)objdump

HOST_CC   = gcc
HOST_CXX  = g++
HOST_LD   = $(HOST_CC)
HOST_LDXX = $(HOST_CXX)


prefix    = /usr/local
packdir   =
sysroot   = 

#  -std=gnu99 -std=c+11