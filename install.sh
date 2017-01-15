#!/bin/bash

DO_ROOT=0
DO_SIMULATE=0
DO_STOWOPT="--ignore='stow\-.*\-host'"

stow_it()
{
	local STOWDIR="$1"
	shift 1

	# check if I should execute this on this host
	if [ -f $i/stow-on-host ]; then
		if grep -q $HOSTNAME $i/stow-on-host; then
			:
		else
			echo "$i/stow-on-hosts doesn't like me"
			return
		fi
	fi
	if [ -f $i/stow-not-on-host ]; then
		if grep -qw $HOSTNAME $i/stow-not-on-host; then
			echo "$i/stow-not-on-hosts doesn't like me"
			return
		fi
	fi

	echo "--> stowing $STOWDIR"
	if [ "$DO_SIMULATE" = "0" ]; then
		eval $*
	fi
}


for i in *; do
	# only care for directories
	test -d "$i" || continue

	if [ "$i" = "${i#root-}" ]; then
		test "$DO_ROOT" = "1" && continue
		#echo no-root $i
		stow_it "$i" stow $DO_STOWOPT --adopt "$i"
	else
		test "$DO_ROOT" = "0" && continue
		echo root $i
	fi
done


#sudo stow -t / root-alarm
