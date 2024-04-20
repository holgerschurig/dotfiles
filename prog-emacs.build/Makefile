# The first target is run if you call "make" without any arguments. Let's output
# some help, i.E. what targets this Makefile supports.
help::

# Used to protect some makefile targets to be run as root. Or to elevate to root
# for those things where this is needed (e.g. installing)
UID := $(shell id -u)


pull emacs.git/.git/HEAD:
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
ifeq ("$(wildcard emacs.git)","")
	git clone --single-branch --branch=emacs-29 git://git.savannah.gnu.org/emacs.git emacs.git
else
	@# sometimes, if we have old compilation artefacts, the configure step will behave weird.
	cd emacs.git; git clean -fdx
	cd emacs.git; git pull
endif
help::
	@echo "make pull             clone or pull Emacs from git"



ifeq ($(WAYLAND_DISPLAY),)
# The X11/Lucid settings:
EMACS_EXTRA_CONF+=--with-x-toolkit=lucid
EMACS_EXTRA_CONF+=--without-toolkit-scroll-bars
EMACS_EXTRA_CONF+=--without-xft
EMACS_EXTRA_CONF+=--without-xaw3d
else
# The Waylands settings:
EMACS_EXTRA_CONF=--with-pgtk
endif

emacs.git/configure: emacs.git/.git/HEAD
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	cd emacs.git; ./autogen.sh

confemacs emacs.git/Makefile: emacs.git/configure
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	cd emacs.git; \
	./configure \
		$(EMACS_EXTRA_CONF) \
		-C \
		--with-cairo \
		--with-dbus \
		--with-file-notification=inotify \
		--with-gnutls \
		--with-gpm=no \
		--with-harfbuzz \
		--without-imagemagick \
		--with-json \
		--with-modules \
		--with-native-compilation=aot \
		--with-rsvg \
		--with-small-ja-dic \
		--with-sound=alsa \
		--with-threads \
		--with-tree-sitter \
		--with-x-toolkit=gtk3 \
		--with-xml2 \
		--without-compress-install \
		--without-gconf \
		--without-gpm \
		--without-gsettings \
		--without-hesiod \
		--without-kerberos \
		--without-kerberos5 \
		--without-ns \
		--without-pop \
		--without-selinux \
		--without-wide-int \
		--without-xinput2 \
		--without-xft \
		--without-xim \
		CFLAGS='-g -O2 -march=native -ffile-prefix-map=/home/holger=. -fstack-protector-strong -Wformat -Werror=format-security -Wall -fno-omit-frame-pointer'
		CPPFLAGS='-Wdate-time -D_FORTIFY_SOURCE=2' \
		LDFLAGS='-Wl,-z,relro'
help::
	@echo "make confemacs        configure Emacs"



compile emacs.git/src/emacs: emacs.git/Makefile
	@test $(UID) != 0 || { echo "\n---> Not as root, dude! ($@)\n"; exit 1; }
	$(MAKE) --no-print-directory $(MFLAGS) -C emacs.git -j $(shell nproc --ignore 4)
help::
	@echo "make compile          compile Emacs from source"



install /usr/local/bin/emacs: emacs.git/src/emacs
ifeq ($(UID),0)
	cd /usr/local/stow; stow --delete emacs || true
	mkdir -p /usr/local/stow
	rm -rf /usr/local/stow/emacs
	$(MAKE) --no-print-directory $(MFLAGS) -C emacs.git install prefix=/usr/local/stow/emacs
	cd /usr/local/stow; stow emacs
else
	sudo $(MAKE) --no-print-directory $(MFLAGS) install
endif
help::
	@echo "make install          install compiled Emacs (using stow)"


uninstall:
ifeq ($(UID),0)
	cd /usr/local/stow; stow --delete emacs
else
	sudo $(MAKE) --no-print-directory $(MFLAGS) uninstall
endif
help::
	@echo "make uninstall        uninstall Emacs (using stow)"



cleansource:
	cd emacs.git; git clean -fdx
help::
	@echo "make cleansource      clean Emacs' source tree"



all: /usr/local/bin/emacs
