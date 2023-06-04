configure:
	sysctl fs.inotify.max_user_instances=256

install:
	cp src/resync.sh /usr/local/bin/resync

install-dev:
	ln -s -T $(realpath src/resync.sh) /usr/local/bin/resync

uninstall:
	rm -rf /usr/local/bin/resync

reinstall: uninstall install

reinstall-dev: uninstall install-dev
