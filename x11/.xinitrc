#!/bin/sh

test -z "$EMAIL" && . /etc/profile

. /etc/default/locale
export LANG
export LANGUAGE
test -z "$DISPLAY" && export DISPLAY=:0

(
	sleep 1

	#pulseaudio --start
	start-pulseaudio-x11

	test `hostname` = laptop && xrandr --output VGA1 --primary --mode 1920x1080

	# Screen saver off
	xset s off
	xset -dpms

	# Turn CAPS LOCK into CTRL, otherwise it's a nuisance
	xmodmap ~/.Xmodmap

	# Swap left and right mouse buttons
	#xmodmap -e "pointer = 3 2 1 4 5 6 7 8 9 10"

	# Terminate X11 with Cltr-Alt-Backspace
	setxkbmap -option terminate:ctrl_alt_bksp de caps:ctrl_modifier
	setxkbmap -variant "nodeadkeys"

	xrdb -merge ~/.Xresources

	test -f /etc/default/unclutter && . /etc/default/unclutter
	test -x /usr/bin/unclutter && /usr/bin/unclutter ${EXTRA_OPTS} &
	unset EXTRA_OPTS
) &

mkdir -p ~/.cache/awesome
exec awesome >~/.cache/awesome/stdout 2>~/.cache/awesome/stderr
