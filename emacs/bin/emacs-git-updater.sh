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

	for i in ${1}*/.git; do
		# We get this weird string when we don't find a match
		test $i = "${1}*/.git" && break
		D=${i%/.git}

		# Use a ( so that even in case of a failure we end up in our directory
		(
			cd $D
			DATE=`git show --format=format:%ai | head -n1`
			echo "$DATE  $D"
		)
	done
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
	# Changed in 2017-01
	clone confevilivy  https://github.com/redguardtoo/emacs.d               redguardtoo
	clone confivy      https://github.com/abo-abo/oremacs.git               aboabo
	clone confevilhelm https://github.com/jwiegley/dot-emacs.git            jwiegley
	clone confhelm     https://github.com/angrybacon/dotemacs.git           angrybacon
	clone confevilhelm https://github.com/dakrone/eos.git                   eos
	clone confivy      https://github.com/kaushalmodi/.emacs.d.git          kaushalmodi
	clone confhelm     https://github.com/sachac/.emacs.d.git               sachac
	clone confhelm     https://github.com/bodil/ohai-emacs.git              ohai
	#clone confhelm     https://github.com/mordocai/emacs.d.git              mordocai
	clone confhelm     https://github.com/sri/dotfiles.git                  sri
	clone confhelm     https://github.com/bbatsov/prelude.git               prelude
	clone confivy      https://github.com/skeeto/.emacs.d.git               skeeto
	clone confivy      https://github.com/purcell/emacs.d.git               purcell
	clone conf         https://github.com/novoid/Memacs.git                 memacs

	# Changed in 2016-12
	clone conf         https://github.com/skybert/my-little-friends.git     skybert
	clone confhelm     https://github.com/sigma/dotemacs.git                sigma
	clone confhelm     https://github.com/Fuco1/.emacs.d.git                fuco1
	clone conf         https://github.com/chrisdone/chrisdone-emacs.git     chrisdone

	# Changed in 2016-11
	clone conf         https://github.com/novoid/dot-emacs.git              voit
	clone confevilhelm https://github.com/milkypostman/dotemacs.git         milkypostman
	clone confivy      https://github.com/lunaryorn/.emacs.d.git            lunaryorn
	clone confhelm     https://github.com/tuhdo/emacs-c-ide-demo.git        tuhdo

	# Changed in 2016-10
	clone confhelm     https://github.com/bashrc/emacs.git                  bashrc
	clone conf         https://github.com/jd/emacs.d.git                    danjou
	clone conf         https://github.com/higham/dot-emacs.git              higham

	# Not changed for a while ...
	clone oldhelm      https://github.com/jkitchin/jmax.git                 kitchin
	clone old          https://github.com/magnars/.emacs.d.git              magnars
	clone old          https://github.com/grettke/home.git                  grettke
}


clone_elpa()
{
	# You can find the URLs via http://melpa.milkbox.net/#/


	# Changed in 2017:
	clone elpa https://github.com/jorgenschaefer/circe.git
	clone elpa https://github.com/flycheck/flycheck.git
	clone elpa https://github.com/magit/magit.git
	clone elpa https://github.com/emacs-helm/helm.git
	clone elpa https://github.com/abo-abo/hydra.git
	clone elpa https://github.com/rust-lang/rust-mode.git
	clone elpa https://github.com/fxbois/web-mode.git
	clone elpa https://github.com/bbatsov/zenburn-emacs

	# Changed in 2016-12
	clone elpa https://github.com/jwiegley/use-package.git
	clone elpa https://github.com/jacktasia/dumb-jump.git
	clone elpa https://github.com/skeeto/elfeed.git
	clone elpa https://github.com/xiongtx/eros.git
	clone elpa https://github.com/dominikh/go-mode.el.git
	clone elpa https://github.com/hniksic/emacs-htmlize.git
	clone elpa https://github.com/mooz/js2-mode.git
	clone elpa https://github.com/hlissner/emacs-pug-mode.git
	clone elpa https://github.com/justbur/emacs-which-key.git
	clone elpa https://github.com/magit/with-editor.git

	# Changed in 2016-11
	# async
	# dash
	clone elpa https://github.com/magnars/expand-region.el.git
	clone elpa https://github.com/pidu/git-timemachine.git
	# lua-mode
	clone elpa https://github.com/Malabarba/paradox.git
	clone elpa https://github.com/milkypostman/powerline.git
	# toml-mode
	clone elpa https://github.com/jinzhu/zeal-at-point.git

	# Changed in 2016-10
	# d-mode
	clone elpa https://github.com/rejeep/f.el.git
	clone elpa https://github.com/emacsfodder/kurecolor.git
	clone elpa https://github.com/emacsmirror/undo-tree.git

	# Changed in 2016-09
	clone elpa https://github.com/cute-jumper/avy-zap.git
	clone elpa https://github.com/emacs-helm/helm-descbinds.git
	clone elpa https://github.com/pronobis/helm-flyspell.git
	clone elpa https://github.com/magnars/s.el.git
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
