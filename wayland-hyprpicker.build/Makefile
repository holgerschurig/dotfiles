# The first target is run if you call "make" without any arguments. Let's output
# some help, i.E. what targets this Makefile supports.
help::

# Used to protect some makefile targets to be run as root. Or to elevate to root
# for those things where this is needed (e.g. installing)
UID := $(shell id -u)



pull hyprpicker.git/.git/HEAD:
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
ifeq ("$(wildcard hyprpicker.git)","")
	git clone https://github.com/hyprwm/hyprpicker hyprpicker.git
else
	cd hyprpicker.git; git pull
endif
help::
	@echo "make pull               clone or pull hyprpicker from git"

compile hyprpicker.git/build/hyprpicker: hyprpicker.git/.git/HEAD
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	cd hyprpicker.git; cmake -B build
	cd hyprpicker.git; cmake --build build -j
	touch --no-create hyprpicker.git/build/hyprpicker
help::
	@echo "make compile            compile hyprpicker from source"

install /usr/local/bin/hyprpicker: hyprpicker.git/build/hyprpicker
ifeq ($(UID),0)
	mkdir -p /usr/local/stow
	cd /usr/local/stow; stow --delete hypr || true
	cd hyprpicker.git; cmake --install build --prefix /usr/local/stow/hyprpicker
	cd /usr/local/stow; stow hyprpicker
	touch --no-create /usr/local/bin/hyprpicker
else
	sudo $(MAKE) --no-print-directory $(MFLAGS) install
endif
help::
	@echo "make install            install compiled hyprpicker (using stow)"
	@echo


all: /usr/local/bin/hyprpicker
