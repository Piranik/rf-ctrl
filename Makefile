#
# Copyright (C) 2016 Jean-Christophe Rona <jc@rona.fr>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

GNU_PREFIX ?=

# Allow to create a static binary
STATIC ?= false

# Use an external implementation of iconv instead of the libc's one
USE_EXTERNAL_LIBICONV ?= false

# Enable Alsa support
ENABLE_ALSA ?= true

# Where to install the software
INSTALLATION_PATH ?= /usr/local/bin

# Where the configuration file should be placed
CONFIGURATION_FILE_LOCATION ?= /etc


CONFIGURATION_FILE = $(TARGET).conf

CFLAGS += -DCONFIG_FILE_LOCATION=\"$(CONFIGURATION_FILE_LOCATION)\"

ifeq ($(STATIC), true)
	LDFLAGS += -static
endif

CC=$(GNU_PREFIX)gcc
LD=$(GNU_PREFIX)ld

LDLIBS = -lusb-1.0 -lpthread -lm

ifeq ($(USE_EXTERNAL_LIBICONV), true)
	LDLIBS += -liconv
endif

ifeq ($(STATIC), true)
	LDLIBS += -lgcc_eh
endif

TARGET = rf-ctrl
OBJECTS = he853.o ook-gpio.o sysfs-gpio.o dummy.o otax.o dio.o home-easy.o idk.o sumtech.o auchan.o auchan2.o somfy.o blyss.o rf-ctrl.o hid-libusb.o raw.o

ifeq ($(ENABLE_ALSA), true)
	LDLIBS += -lasound
	CFLAGS += -DALSA_ENABLED
	OBJECTS += alsa.o
endif

all: $(TARGET)

$(TARGET): $(OBJECTS)
	@echo
	@echo -n "Linking ..."
	@$(CC) $(CFLAGS) $(LDFLAGS) $+ -o $@ $(LDLIBS)
	@echo " -> $@"
	@echo

install:
	install -D $(TARGET) $(INSTALLATION_PATH)
	install -D $(CONFIGURATION_FILE) $(CONFIGURATION_FILE_LOCATION)

clean:
	$(RM) $(OBJECTS) $(TARGET)

%.o : %.c
	@echo "[$@] ..."
	@$(CC) $(CFLAGS) -c $< -o $@

.PHONY: all clean
