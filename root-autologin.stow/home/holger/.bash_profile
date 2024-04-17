test "`readlink /proc/self/fd/0`" = "/dev/tty7" -a -z "$XDG_VTNR" && {
        exit
}

test "$XDG_VTNR" == "7" -a -z "$DISPLAY" && {
        chvt 7 2>/dev/null
        exec /usr/bin/startx
}
