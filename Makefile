prefix = /usr

all: src/hello


src/hello: src/hello.c
	@echo "CFLAGS=$(CFLAGS)" | \
		fold -s -w 70 | \
		sed -e 's/^/# /'
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDCFLAGS) -o $@ $^

install: src/hello
	install -D src/hello \
		$(DESTDIR)$(prefix)/bin/helloworld

clean:
	-rm -f src/hello

distclean: clean
	-rm -rf packages

uninstall:
	-rm -f $(DESTDIR)$(prefix)/bin/helloworld

deb:

	deploy/build_deb.sh $(VERSION)


.PHONY: all install clean distclean uninstall


