# The first target is run if you call "make" without any arguments. Let's output
# some help, i.E. what targets this Makefile supports.
help::

# Used to protect some makefile targets to be run as root. Or to elevate to root
# for those things where this is needed (e.g. installing)
UID := $(shell id -u)
NPROC := $(shell nproc --ignore 8)



pullscanner hyprwayland-scanner.git/.git/HEAD:
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
ifeq ("$(wildcard hyprwayland-scanner.git)","")
	git clone https://github.com/hyprwm/hyprwayland-scanner hyprwayland-scanner.git
else
	cd hyprwayland-scanner.git; git pull
endif
help::
	@echo "make pullscanner      clone or pull hyprwayland-scanner from git"

compscanner hyprwayland-scanner.git/build/hyprwayland-scanner: hyprwayland-scanner.git/.git/HEAD
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	cd hyprwayland-scanner.git; cmake -B build
	cd hyprwayland-scanner.git; cmake --build build -j
	touch --no-create $@
help::
	@echo "make compscanner      compile hyprwayland-scanner from source"

.PHONY:: instscanner
instscanner /usr/local/bin/hyprwayland-scanner: hyprwayland-scanner.git/build/hyprwayland-scanner
ifeq ($(UID),0)
	mkdir -p /usr/local/stow
	cd /usr/local/stow; stow --delete hypr || true
	cd hyprwayland-scanner.git; cmake --install build --prefix /usr/local/stow/hypr
	cd /usr/local/stow; stow hypr
	touch --no-create /usr/local/bin/hyprwayland-scanner
else
	sudo $(MAKE) --no-print-directory $(MFLAGS) instscanner
endif
help::
	@echo "make instscanner      install compiled hyprwayland-scanner library (using stow)"
	@echo




pulllang hyprlang.git/.git/HEAD:
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
ifeq ("$(wildcard hyprlang.git)","")
	git clone https://github.com/hyprwm/Hyprlang hyprlang.git
else
	cd hyprlang.git; git pull
endif
help::
	@echo "make pulllang         clone or pull hyprlang from git"

complang hyprlang.git/build/hyprlang.pc: hyprlang.git/.git/HEAD
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	cd hyprlang.git; cmake -B build
	cd hyprlang.git; cmake --build build -j
	touch --no-create hyprlang.git/build/hyprlang.pc
help::
	@echo "make complang         compile hyprlang from source"

instlang /usr/local/lib/libhyprlang.so: hyprlang.git/build/hyprlang.pc
ifeq ($(UID),0)
	mkdir -p /usr/local/stow
	cd /usr/local/stow; stow --delete hypr || true
	cd hyprlang.git; cmake --install build --prefix /usr/local/stow/hypr
	cd /usr/local/stow; stow hypr
	touch --no-create /usr/local/lib/libhyprlang.so
else
	sudo $(MAKE) --no-print-directory $(MFLAGS) instlang
endif
help::
	@echo "make instlang         install compiled hyprlang library (using stow)"
	@echo




pullcursor hyprcursor.git/.git/HEAD:
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
ifeq ("$(wildcard hyprcursor.git)","")
	git clone https://github.com/hyprwm/Hyprcursor hyprcursor.git
else
	cd hyprcursor.git; git pull
endif
help::
	@echo "make pullcursor       clone or pull hyprcursor from git"

compcursor hyprcursor.git/build/hyprcursor.pc: hyprcursor.git/.git/HEAD /usr/local/lib/libhyprlang.so
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	cd hyprcursor.git; cmake -B build
	cd hyprcursor.git; cmake --build build -j
help::
	@echo "make compcursor       compile hyprcursor library from source"

instcursor /usr/local/lib/libhyprcursor.so: hyprcursor.git/build/hyprcursor.pc
ifeq ($(UID),0)
	mkdir -p /usr/local/stow
	cd /usr/local/stow; stow --delete hypr || true
	cd hyprcursor.git; cmake --install build --prefix /usr/local/stow/hypr
	cd /usr/local/stow; stow hypr
	touch --no-create /usr/local/lib/libhyprcursor.so
else
	sudo $(MAKE) --no-print-directory $(MFLAGS) instcursor
endif
help::
	@echo "make instcursor       install compiled hyprcursor library (using stow)"
	@echo




pullland hyprland.git/.git/HEAD:
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
ifeq ("$(wildcard hyprland.git)","")
	git clone --recursive https://github.com/hyprwm/Hyprland hyprland.git
else
	cd hyprland.git; git pull --recurse-submodules=yes
endif
help::
	@echo "make pullland         clone or pull Hyprland from git"

compland hyprland.git/build/Hyprland: \
		hyprland.git/.git/HEAD \
		/usr/local/bin/hyprwayland-scanner \
		/usr/local/lib/libhyprlang.so \
		/usr/local/lib/libhyprcursor.so
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	cd hyprland.git; cmake -B build
	cd hyprland.git; cmake --build build -j $(NPROC)
help::
	@echo "make compland         compile Hyprland from source"

instland /usr/local/bin/Hyprland: hyprland.git/build/Hyprland
ifeq ($(UID),0)
	mkdir -p /usr/local/stow
	cd /usr/local/stow; stow --delete hypr || true
	install -s hyprland.git/build/Hyprland /usr/local/stow/hypr/bin
	install -s hyprland.git/build/hyprctl/hyprctl /usr/local/stow/hypr/bin
	install -s hyprland.git/build/hyprpm/hyprpm /usr/local/stow/hypr/bin
	cd /usr/local/stow; stow hypr
else
	sudo $(MAKE) --no-print-directory $(MFLAGS) instland
endif
help::
	@echo "make instland         install Hyprland compositor (using stow)"
	@echo







uninstall:
ifeq ($(UID),0)
	cd /usr/local/stow; stow --delete hypr
else
	sudo $(MAKE) --no-print-directory $(MFLAGS) uninstall
endif
help::
	@echo "make uninstall        uninstall all of the above"
	@echo



cleansource:
	cd hyprland.git; git clean -fdx
help::
	@echo "make cleansource      clean Hyprland' source tree"



all: /usr/local/bin/Hyprland
