OS:=$(shell uname | sed 's/[-_].*//')
CFLAGS=-Wall -O2 -fPIC
#CFLAGS=-Wall -fPIC -ggdb
SHARED=-shared
SOEXT:=.so

objects = tokens.o paragraph.o
headers = tokens.h paragraph.h breakpoint.h

ifeq (${OS},Darwin)
  SHARED = -dynamiclib
  SOEXT:=.bundle
endif

all: crawdad$(SOEXT)

crawdad$(SOEXT): $(objects)
	$(CC) $(SHARED) -o crawdad$(SOEXT) $(objects)

%.o: %.c $(headers)
	$(CC) -c -o $@ $< $(CFLAGS)

clean:
	rm *.o *$(SOEXT)

