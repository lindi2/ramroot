all:
	bash create-initial-snapshot
	bash configure-initial-snapshot
	bash minimize-initial-snapshot
	bash create-flash-image

# cp img img.test ; bash boot-with-qemu img.test
# script -c 'bash testsuite/all-in-one localhost 8022' testsuite/all-in-one.log

