#
# This Makefile has actually nothing to do with the dotfiles themselves. But ...
# it can be used to check this project inside a Docker (or actually: Podman)
# container. Better than always reinstalling my Laptop :-)
#

UID := $(shell id -u)

help::
	@echo "This makefile is just use to test the dotfiles in a docker container."
	@echo "Possible pseudo-targets are:"
	@echo


# Shows all images and containers
status:
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	@echo
	podman image list
	@echo
	podman container list --all
	@echo
help::
	@echo "status         show status of images and containers"



# Debian 12 ("Bookworm") – aktuelle Veröffentlichung - "Stable"
# Debian 11 ("Bullseye") – aktuelle Veröffentlichung - "Oldstable"
# Debian 10 ("Buster") – aktuelle Veröffentlichung - "Oldoldstable"
DEBIAN_RELEASE=bookworm
ARCH=amd64


# This Makefile helper imports a minimal debian image created with "debootstrap"
# and makes it a podman image.
debootstrap: debootstrap.$(DEBIAN_RELEASE).$(ARCH).tar.gz
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	@grep -q 1 /proc/sys/kernel/unprivileged_userns_clone || echo "Make sure /proc/sys/kernel/unprivileged_userns_clone is set via sysctl"
	podman rmi --ignore --force localhost/debootstrap.$(DEBIAN_RELEASE).$(ARCH)
	podman import debootstrap.$(DEBIAN_RELEASE).$(ARCH).tar.gz $(DEBIAN_RELEASE).$(ARCH).debootstrap
help::
	@echo "debootstrap    create image from existing debootstrap .tar.gz"


# This Makefile helper target tries to run (podman start) first an already
# existing container. However, if that container doesn't exist, then it will be
# created.
run:
	test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	mkdir -p .podman-downloads
	podman start \
		--interactive \
		--attach \
		$(DEBIAN_RELEASE).$(ARCH).test || \
	podman run \
		--mount type=bind,source=.podman-downloads,destination=/var/cache/apt/archives,rw \
		--mount type=bind,source=.,destination=/root/dotfiles,rw \
		--tty \
		--interactive \
		--hostname apply \
		--name $(DEBIAN_RELEASE).$(ARCH).test \
		localhost/$(DEBIAN_RELEASE).$(ARCH).debootstrap \
		bash -c "cd /root/dotfiles; ./apply -fd root; bash -i"
help::
	@echo "run            create and run --- or, if already existing, re-run container"


# This Makefile helper target removes the container. That means the next
# invocation of "make contrun" will create a new container from the image made
# by "make contdebootstrap"
del:
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	podman rm --ignore --force bookworm.amd64.test
help::
	@echo "del            delete container (so that next run will start afresh)"
