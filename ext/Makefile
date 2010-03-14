OS:=$(shell uname | sed 's/[-_].*//')
CFLAGS=-Wall -O2 -fPIC
SHARED=-shared
SOEXT:=.so

objects = paragraph.o
headers = tokens.h paragraph.h

ifeq (${OS},Darwin)
  SHARED = -dynamiclib
  SOEXT:=.bundle
endif

all: crawdad$(SOEXT)

crawdad$(SOEXT): $(objects)
	gcc $(SHARED) -o crawdad$(SOEXT) $(objects)

%.o: %.c $(headers)
	gcc -c -o $@ $< $(CFLAGS)

clean:
	rm *.o *.$(SOEXT)

