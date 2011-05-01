DEBUG = -g -DNOPERL
AM_CFLAGS = -Wall -Werror -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations $(DEBUG) -I/usr/include -I../ -I../../ -I/usr/X11R6/include -I/usr/X/include
AM_LDFLAGS = -O2 -L/usr/lib -L/usr/X11R6/lib -L/usr/X/lib -lXtst -lXext -lX11 -lpopt # -lefence 

bindir = $(prefix)/bin
bin_PROGRAMS = x11guirecord
x11guirecord_SOURCES = ../../KeyUtil.c record.c script_file.c main.c

