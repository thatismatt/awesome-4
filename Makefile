.PHONY: all clean watch

FNLS = $(wildcard *.fnl)
LUAS := $(addsuffix .lua,$(basename $(FNLS)))

%.lua: %.fnl
	fennel --compile $^ > $@

all: $(LUAS)

clean:
	rm $(LUAS)

watch:
	fennel-watch.sh .
