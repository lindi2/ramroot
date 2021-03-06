# Introduction

ramroot is a tool for building embedded-like systems with Debian on
commodity hardware. The main idea is that the root filesystem is a
tmpfs that is populated during boot from a snapshot that is read from
disk. No changes persist unless you create a new snapshot.

# Initial use

When you have booted the image for the first time you can login on the
local console as root with the password `ramroot`. SSH access is
allowed as root as well but only with an SSH key. The build process
copies the initial public key from `~/.ssh/id_rsa.pub`.

The SSH server private key is generated during the build. For
production use you should regenerate the keys as follows:

```
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server
```

When you have made your customizations, remember to run `ramroot
snapshot create DESCRIPTION` to save your work! You can get further
instructions simply by running the command `ramroot` without any
arguments.

# Working with snapshots

When you create a new snapshot the running state of the system is
saved to disk. The `ramroot_uuid` boot option specifies the UUID of
the snapshot store that is used. This allows you to e.g. boot
initially from a USB drive but then later write the USB drive contents
to a local disk. This all works since the filesystem is mounted only
very briefly when you operate on snapshots.

Creating a new snapshot will not change the snapshot that is used on
the next boot. To change the enabled snapshot you need to use the
`ramroot snapshot enable` command. This command will also let you
specify a fallback snapshot. If a fallback is specified, the system
starts a watchdog early in the boot process that needs to be either
stopped with `ramroot watchdog stop` or periodically refreshed with
`ramroot watchdog refresh`. If the watchdog times out the system will
automatically reset and boot to the fallback snapshot. This feature
makes it possible to remotely make large changes to the system without
the fear that the system becomes inaccessible.

# Building

Running `make` on a Debian stable system should produce file called
`img` that you can write to a USB driver or an SSD.

# Testing

Running `make test` on a Debian stable system should make a copy of
`img`, boot it under `kvm` and run a series of tests. If the exit
status is 0 the tests have passed.

# Watchdog

Currently ramroot uses the `softdog` software watchdog of the Linux
kernel. If your hardware supports a proper hardware watchdog you
should use that instead. However, note that hardware watchdogs might
not support long timeouts.

# Esoteric features

Ramroot supports using fusecompress or jffs2 for compression on
machines with low RAM. It can also create an emphemeral root
filesystem automatically on boot to a partition that is marked as
`swap`. These features are not actively tested and may not function
correctly.

# Internals

If you look at a ramroot disk image you can identify the following
layout:

| Location                               | Description                                                                                |
| -------------------------------------- | ------------------------------------------------------------------------------------------ |
| sector 0                               | grub's stage 1                                                                             |
| sectors 1-62                           | grub's core.img                                                                            |
| /boot/grub/grub.cfg                    | grub configuration file that lists all snapshots, generated by `ramroot snapshot enable`   |
| /boot/grub/grub.cfg.info               | ramroot's internal state file, describes how grub.cfg was configured                       | 
| /boot/grub/grubenv                     | grub environment, stores the index of the boot entry that will be booted next              |
| /snapshot/0                            | initial snapshot, contains just a directory tree to be copied to tmpfs                     |
| /snapshot/1                            | second snapshot                                                                            |
| /snapshot/N                            | Nth snapshot                                                                               |

If the same file is part of multiple snapshots the system will try to
use a hardlink to save space.

Inside search snapshot you can see the following structure:

| Location                               | Description                                                                                |
| -------------------------------------- | ------------------------------------------------------------------------------------------ |
| /etc/ramroot/grub-extraopts | Extra kernel options to use for this snapshot when generating master grub.cfg              |
| /etc/ramroot/grub-title     | Grub title to use for this snapshot when generating master grub.cfg                        |
| /etc/ramroot/origin         | Git commit hash that was used to build the initial snapshot                                |
| /etc/ramroot/gitlog.gz      | Last 10 commits of the git repo                                                            |
| /etc/ramroot/size           | Size of the snapshot, used for progress bar on bootup and `ramroot snapshot list` |
| /etc/ramroot/boot-info           | Information on the last successful bootup |
| /etc/initramfs-tools/scripts/local-top/ramroot      | Hook that runs at the very beginning of the initramfs and starts the watchdog |
| /etc/initramfs-tools/scripts/local-premount/ramroot | Hook that handles copying the selected snapshot to `tmpfs` |


The following boot parameters are used:

| Parameter                              | Description                                                                                |
| -------------------------------------- | ------------------------------------------------------------------------------------------ |
| ramroot_uuid                           | UUID used to find the ramroot snapshot filesystem during boot. If this option is not specified the system will look for any filesystem whose UUID begins with `962d307f-8f1f-4301` and use that. |
| ramroot_snapshot                       | ID of the currently running snapshot |
| ramroot_fs                             | Filesystem to use for the running system. This defaults to `tmpfs` and should normally never be specified. |
| ramroot_fs_uuid                        | UUID used to find the swap filesystem for the esoteric `ramroot_fs=swap` use case. If this option is not specified the system will look for any filesystem whose UUID begins with `ffda8257-f78a-4893` |

