CC = gcc
FILES = ../KeyUtil.c record.c script_file.c main.c
DEBUG= -g -DNOPERL
CFLAGS = -Wall -Werror -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations $(DEBUG) -I/usr/include -I../
LFLAGS = -O2 -L/usr/lib -lX11 -lXext -lXtst -lpopt # -lefence 

build: $(FILES)
	$(CC) $(CFLAGS) $(LFLAGS) $(FILES) -o x11guirecord

clean:
	rm -f *.o x11guirecord

install:
	cp -f x11guirecord /usr/bin
	chmod 755 /usr/bin/x11guirecord

