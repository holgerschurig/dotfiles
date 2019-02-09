#!/bin/bash

mkdir -p /usr/src/emacs
cd /usr/src/emacs

update()
{
	local D
	local L
	local i

	for i in ${1}*/.git; do
		# We get this weird string when we don't find a match
		test $i = "${1}*/.git" && break

		D=${i%/.git}
		L=${D}.diff
		L=${L%conf-}
		L=${L%elpa-}

		# Skip any unprocessed diff
		test -f $L && continue

		# Use a ( so that even in case of a failure we end up in our directory
		(
			echo "---> $D"
			cd $D
			git pull 2>&1
			if [ "$i" = "conf-sachac" ]; then
				git log --reverse -p ORIG_HEAD..HEAD . ':(exclude)*.html' >../$L
			else
				git log --reverse -p ORIG_HEAD..HEAD >../$L
			fi
		)

		# Remove an empty logfile
		test -s $L || rm -f $L
	done
}


show_last()
{
	local D
	local DATE
	declare -a KEYS
	declare -lA DATES
	declare -lA URLS

	if [[ $1 == elpa* ]]; then
		KEYS=("-k" "5,5" "-k" "3,3")  # sort by date, then by URL
	else
		KEYS=("-k" "6,6" "-k" "4,4")  # sort by dtae, then by name
	fi

	for i in ${1}*/.git; do
		# We get this weird string when we don't find a match
		test $i = "${1}*/.git" && break
		D=${i%/.git}

		DATE=`cd $D; git show --format=format:%ai | head -n1 | cut -d' ' -f1`
		DATES[$D]="$DATE"
		URLS[$D]=`cd $D; git config remote.origin.url`
		#echo "$DATE $D"
	done
	(
		for D in ${!DATES[@]} ; do
			if [[ $D == elpa-* ]] ; then
				printf "\tclone elpa %-50s # %s\n" "${URLS[$D]}" "${DATES[$D]}"
			else
				printf "\tclone %-12s %-50s %-12s # %s\n" "${D/-*/}" "${URLS[$D]}" "${D/*-/}" "${DATES[$D]}"
			fi
		done
	) | sort -r ${KEYS[*]}
}


clone()
{
	local source="$1"
	local url="$2"
	local name=${url}

	if [ -z "$3" ]; then
		name=${name%.git}
		name=${name%.el}
		name=${name#https://}
		name=${name#http://}
		name=${name#github.com/}
		name=${name/*\//}
	else
		name="$3"
	fi

	test -f $source-$name/.git/config && return
	git clone --depth 100 $url $source-$name
}


clone_conf()
{
	clone confhelm     https://github.com/howardabrams/dot-files          howardabrahms
	clone confivy      https://github.com/purcell/emacs.d.git             purcell      # 2017-10-07
	clone conf         https://github.com/skybert/my-little-friends.git   skybert      # 2017-10-06
	clone confevilivy  https://github.com/redguardtoo/emacs.d             redguardtoo  # 2017-10-06
	clone confivy      https://github.com/skeeto/.emacs.d.git             skeeto       # 2017-10-05
	clone confhelm     https://github.com/fuco1/.emacs.d.git              fuco1        # 2017-10-05
	clone confivy      https://github.com/abo-abo/oremacs.git             aboabo       # 2017-10-05
	clone confivy      https://github.com/kaushalmodi/.emacs.d.git        kaushalmodi  # 2017-10-04
	clone conf         https://github.com/chrisdone/chrisdone-emacs.git   chrisdone    # 2017-10-01
	clone conf         https://github.com/magnars/.emacs.d.git            magnars      # 2017-09-28
	clone confevilhelm https://github.com/dakrone/eos.git                 eos          # 2017-09-26
	clone conf         https://github.com/novoid/dot-emacs.git            voit         # 2017-09-23
	clone confhelm     https://github.com/bashrc/emacs.git                bashrc       # 2017-09-20
	clone conf         https://github.com/novoid/memacs.git               memacs       # 2017-09-16
	clone confhelm     https://github.com/bbatsov/prelude.git             prelude      # 2017-09-12
	clone confhelm     https://github.com/angrybacon/dotemacs.git         angrybacon   # 2017-08-27
	clone conf         https://github.com/jd/emacs.d.git                  danjou       # 2017-08-22
	clone confhelm     https://github.com/sachac/.emacs.d.git             sachac       # 2017-08-04
	clone confevilhelm https://github.com/jwiegley/dot-emacs.git          jwiegley     # 2017-08-01
	clone conf         https://github.com/higham/dot-emacs.git            higham       # 2017-07-31
	clone confhelm     https://github.com/sri/dotfiles.git                sri          # 2017-07-25
	clone confhelm     https://github.com/bodil/ohai-emacs.git            ohai         # 2017-07-05
	clone confivy      https://github.com/lunaryorn/.emacs.d.git          lunaryorn    # 2017-06-30
	clone confevilhelm https://github.com/milkypostman/dotemacs.git       milkypostman # 2017-02-07
	clone confhelm     https://github.com/sigma/dotemacs.git              sigma        # 2016-12-21
	clone confhelm     https://github.com/tuhdo/emacs-c-ide-demo.git      tuhdo        # 2016-11-08
	clone conf         https://github.com/grettke/home.git                grettke      # 2016-04-25
}


clone_elpa()
{
	# You can find the URLs via http://melpa.milkbox.net/#/

	clone elpa https://github.com/magit/magit.git                 # 2017-10-07
	clone elpa https://github.com/flycheck/flycheck.git           # 2017-10-07
	clone elpa https://github.com/abo-abo/swiper                  # 2017-10-07
	clone elpa https://github.com/magit/with-editor.git           # 2017-10-06
	clone elpa https://github.com/fxbois/web-mode.git             # 2017-10-02
	clone elpa https://github.com/skeeto/elfeed.git               # 2017-10-01
	clone elpa https://github.com/mooz/js2-mode.git               # 2017-09-30
	clone elpa https://github.com/hlissner/emacs-pug-mode.git     # 2017-09-30
	clone elpa https://github.com/jwiegley/use-package.git        # 2017-09-25
	clone elpa https://github.com/abo-abo/hydra.git               # 2017-09-25
	clone elpa https://github.com/darwinawardwinner/amx           # 2017-09-23
	clone elpa https://github.com/magnars/s.el.git                # 2017-09-22
	clone elpa https://github.com/rust-lang/rust-mode.git         # 2017-09-20
	clone elpa https://github.com/jacktasia/dumb-jump.git         # 2017-09-18
	clone elpa https://github.com/malabarba/paradox.git           # 2017-09-15
	clone elpa https://github.com/abo-abo/avy                     # 2017-08-19
	clone elpa https://github.com/justbur/emacs-which-key.git     # 2017-08-17
	clone elpa https://github.com/emacsfodder/kurecolor.git       # 2017-08-08
	clone elpa https://github.com/dominikh/go-mode.el.git         # 2017-07-26
	clone elpa https://github.com/hniksic/emacs-htmlize.git       # 2017-07-17
	clone elpa https://github.com/milkypostman/powerline.git      # 2017-07-08
	clone elpa https://github.com/emacsmirror/undo-tree.git       # 2017-07-06
	clone elpa https://github.com/magnars/expand-region.el.git    # 2017-05-14
	clone elpa https://github.com/bbatsov/zenburn-emacs           # 2017-05-11
	clone elpa https://github.com/jinzhu/zeal-at-point.git        # 2017-04-28
	clone elpa https://github.com/rejeep/f.el.git                 # 2017-04-04
	clone elpa https://github.com/pidu/git-timemachine.git        # 2017-03-25
	clone elpa https://github.com/xiongtx/eros.git                # 2016-12-21
	clone elpa https://github.com/cute-jumper/avy-zap.git         # 2016-09-21
}




DO_CLONE_CONF=0
DO_CLONE_ELPA=0
DO_SHOW_LAST=0

while getopts ":cel" opt; do
	case $opt in
		c)
			DO_CLONE_CONF=1
			;;
		e)
			DO_CLONE_ELPA=1
			;;
		l)
			DO_SHOW_LAST=1
			;;
	esac
done
shift $((OPTIND-1))

if [ -z "$1" ]; then
	DO_ARGS="conf"
else
	DO_ARGS="$1"
fi


test "$DO_CLONE_CONF" = "1" && {
	clone_conf
	DO_STOP=1
}
test "$DO_CLONE_ELPA" = "1" && {
	clone_elpa
	DO_STOP=1
}
test "$DO_STOP" = "1" && exit 0
test "$DO_SHOW_LAST" = "1" && {
	show_last $DO_ARGS
	exit 0
}
update $DO_ARGS
