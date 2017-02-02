#!/bin/bash

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
			#echo "$i/stow-not-on-hosts doesn't like me"
			return
		fi
	fi

	if [ "$DO_SIMULATE" = "0" ]; then
		echo "--> stowing $STOWDIR"
		eval $*
	else
		echo $*
	fi
}


stow_nonroot()
{
	for i in *; do
		# only care for directories
		test -d "$i" || continue

		if [ "$i" = "${i#root-}" ]; then
			test "$DO_ROOT" = "1" && continue
			stow_it "$i" stow $DO_STOWOPT --adopt "$i"
		fi
	done
}

stow_root()
{
	for i in *; do
		# only care for directories
		test -d "$i" || continue

		if [ "$i" = "${i#root-}" ]; then
			:
		else
			test "$DO_ROOT" = "1" && continue
			stow_it "$i" stow $DO_STOWOPT -t / --adopt "$i"
		fi
	done
}


if [ "$UID" = "0" ]; then
	stow_root
else
	stow_nonroot
fi
