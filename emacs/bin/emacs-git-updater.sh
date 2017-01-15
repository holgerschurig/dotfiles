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
			git log --reverse -p ORIG_HEAD..HEAD . ':(exclude)*.html' >../$L
		)

		# Remove an empty logfile
		test -s $L || rm -f $L
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
	echo git clone --depth 100 $url $source-$name
}


clone_conf()
{
	# Changed in 2017:
	clone conf https://github.com/angrybacon/dotemacs.git           angrybacon
	clone conf https://github.com/abo-abo/oremacs.git               aboabo
	clone conf https://github.com/kaushalmodi/.emacs.d.git          kaushalmodi
	clone conf https://github.com/sri/dotfiles.git                  sri
	clone conf https://github.com/sachac/.emacs.d.git               sachac
	clone conf https://github.com/redguardtoo/emacs.d               redguardtoo
	clone conf https://github.com/purcell/emacs.d.git               purcell
	clone conf git://github.com/bbatsov/prelude.git                 prelude
	clone conf https://gitlab.com/mordocai/emacs.d.git              mordocai
	clone conf https://github.com/jwiegley/dot-emacs.git            jwiegley
	clone conf https://github.com/skybert/my-little-friends.git     skybert
	clone conf https://github.com/sigma/dotemacs.git                sigma
	clone conf https://github.com/grettke/home.git                  grettke

	# Changed in 2016-12
	clone conf https://github.com/Fuco1/.emacs.d.git                fuco1
	clone conf https://github.com/chrisdone/chrisdone-emacs.git     chrisdone

	# Changed in 2016-11
	clone conf https://github.com/tuhdo/emacs-c-ide-demo.git        tuhdo
	clone conf https://github.com/milkypostman/dotemacs.git         milkypostman
	clone conf https://github.com/lunaryorn/.emacs.d.git            lunaryorn

	# Not changed for a while ...
	clone conf https://github.com/magnars/.emacs.d.git              magnars
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

clone_conf
clone_elpa


if [ -z "$1" ]; then
	update conf-
else
	update ${1}-
fi
