# Copyright (C) 2009 Tim Brandon
#  Distributed under the GNU GENERAL PUBLIC LICENSE (GPL) Version 2 (June 1991).
#  See the "COPYING" file distributed with this software for more information.


# Makefile for C language and ARV targets
# `make help` for a list of possible targets

# ---
# Adjust the settings below as required for the project

# The name of the main file without extension
PROJECT = motorVoltage

# Host communitations channel to the hardware
# Can use wildcards, e.g. /dev/ttyUSB*
PORT = /dev/ttyUSB*

# Set you CPU-type (MicroController-Unit) here
# For possible MCUs, try `avr-gcc -v --help`
MCU = attiny44

# ---
# AVR dude settings

# Set this to the type of programmer you have
# For possible programmers try 'avrdude -c --help'
AVRDUDE_PROGRAMMER = jtag2isp
AVRDUDE_PORT = usb

# Part name as given to avrdude. May be slighty different than the MCU.
# For a list of possible part names, try `avrdude -c arduino`
AVRDUDE_PART = t44

# Override clocking rate (For serial programmers), aprox. microseconds
# Had to slow the mkII down to talk to the tiny44 w/current setup
AVRDUDE_BITCLOCK = 10

AVRDUDE_EXTRAFLAGS = -y
# -qq

# ---
# --Nothing below this line usually requires modification

# Directory for build files
BUILD = build

# ---
# Set program path/names
CC = avr-gcc
CXX = avr-g++
LD = $(CC)
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
SIZE = avr-size
NM = avr-nm
AVRDUDE = avrdude
RM = rm -f
MV = mv -f

# ---
# Flags for compilation and linking

# List any non-arduino libraries required here
#LIBS = -lm

DEBUG = -gstabs -g3 -save-temps

OPT = -Os
# -mcall-prologues

CWARN = -Wall -Wunused -Wextra -Wpointer-arith -Wstrict-prototypes -Winline \
       	-Wunreachable-code -Wundef -pedantic -Wno-main

CTUNING = -finline-functions -funsigned-char -funsigned-bitfields \
	  -fpack-struct -fshort-enums -fweb -frename-registers -funroll-loops \
	  -fwhole-program -combine
# For further paramaters see `avr-gcc --help=params

#ASFLAGS = -Wa,-adhlns=$(<:.S=.lst),-gstabs

CDEFS =

CINC = -I$(ACORE)

CPPFLAGS = -mmcu=$(MCU)
LDFLAGS = $(DEBUG) $(LIBS) -mmcu=$(MCU) -Wl,-Map=$(PROJECT).map
CFLAGS = -std=gnu99 -mmcu=$(MCU) -I. $(DEBUG) $(OPT) $(CWARN) $(CDEFS) $(CINC)


# ---
# avrdude settings

AVRDUDE_PORT = usb
AVRDUDE_WRITE_FLASH = -U flash:w:$(PROJECT).hex
AVRDUDE_FLAGS =

# ---
# targets

NIL = distclean clean help
PHONY = all tags

# Default target
all: hex

help:
	@echo ' all (default)  same as "hex"'
	@echo ' hex            generate machine code program'
	@echo ' elf            compile and link program'
	@echo ' burn           upload code to avr flash memory'
	@echo ' verify         compare latest code to avr flash memory'
	@echo ' clean          remove most generated files'
	@echo ' distclean      remove all generated files'
	@echo ' tags           generated ctags index file'
	@echo ' stats          show memory use statistics'
	@echo ' dis            produce disassembly listing (.dis)'
	@echo ' '

clean:
	-$(RM) $(PROJECT) *.o *.i *.s *.d *.map *.dis

distclean: clean
	-$(RM) *.bak *.elf *.hex tags

tags:
	ctags *.[ch]

stats: $(PROJECT).elf
	$(OBJDUMP) -h $(PROJECT).elf
# Make this better

# FIXME see arduino stuff
size: sizebefore sizeafter

elf: $(PROJECT).elf
hex: $(PROJECT).hex
dis: $(PROJECT).dis

burn: hex
	$(AVRDUDE) $(AVRDUDE_EXTRAFLAGS) -c $(AVRDUDE_PROGRAMMER)\
	    -B $(AVRDUDE_BITCLOCK) -P $(AVRDUDE_PORT) -p $(AVRDUDE_PART)\
	    -U flash:w:$(PROJECT).hex

verify: hex
	$(AVRDUDE) $(AVRDUDE_EXTRAFLAGS) -c $(AVRDUDE_PROGRAMMER)\
	    -B $(AVRDUDE_BITCLOCK) -P $(AVRDUDE_PORT) -p $(AVRDUDE_PART)\
	    -U flash:v:$(PROJECT).hex

.PHONY: $(PHONY) $(NIL)
SRC = $(wildcard *.c)

# ---
# rules

# Handle dependencies automatically in (GNU-make/gcc)-style
%.d: %.c
	$(CC) -MM $(CPPFLAGS) $< > $@.$$$$; \
	    sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	    rm -f $@.$$$$

# Include auto-dependency files
# Wrap w/conditional to avoid make-dep on NIL targets
ifeq (,$(filter $(NIL),$(MAKECMDGOALS)))
-include $(SRC:.c=.d)
endif

$(PROJECT).elf: $(SRC:.c=.o)
	$(LD) $(LDFLAGS) $(SRC:.c=.o) -o $@

%.dis: %.elf
	$(OBJDUMP) -h -S -D $< > $@

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

