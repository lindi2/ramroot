all:
	bash install-dependencies
	bash create-initial-snapshot
	bash configure-initial-snapshot
	bash minimize-initial-snapshot
	bash create-flash-image

test:
	cp img img.test
	screen -d -m -S ramroot-test bash boot-with-qemu img.test
	script -c 'bash testsuite/all-in-one localhost 8022' testsuite/all-in-one.log
	screen -S ramroot-test -X kill

