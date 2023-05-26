install:
	cp src/resync.sh /usr/local/bin/resync

install-dev:
	ln -s -T $(realpath src/resync.sh) /usr/local/bin/resync

uninstall:
	rm -rf /usr/local/bin/resync
