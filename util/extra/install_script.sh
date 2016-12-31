#/usr/bin/env bash

echo "Installing Swift Robot Environment"$'\n'

function err {
	echo \> $'\033[0;31m'$*$'\033[0m' >&2
	exit 127
}

function log {
	echo ⚙ $'\033[0;32m'$*$'\033[0m'
}

function newline {
	echo # ¬¬
}

DESTDIR=~/.swiftyrobot

mkdir -p $DESTDIR || err "Couldn't create destination directory: $DESTDIR"
/usr/bin/env git version > /dev/null 2> /dev/null || err "Please install git."
/usr/bin/env docker > /dev/null 2> /dev/null || err "Please install docker. "$'\n\t'"Ubuntu: https://docs.docker.com/engine/installation/linux/ubuntulinux/"$'\n\t'"Mac: https://docs.docker.com/docker-for-mac/"
/usr/bin/env docker ps > /dev/null 2> /dev/null || err "Please start docker."

if [[ -d $DESTDIR ]]; then
	log "Removing old version..."
	rm -rf $DESTDIR # Probably a git pull in the future?
fi

log "Fetching last version..."
/usr/bin/env git clone https://github.com/gonzalolarralde/swifty-robot-environment.git $DESTDIR -q || err "Couldn't clone Swifty Robot Environment repository"

if [[ ":$PATH:" == *":$DESTDIR:"* ]]; then
	log "Swifty Robot Environment already in PATH :)"
else
	if [[ $SHELL == *"bash"* ]]; then
		echo "export PATH=\$PATH:$DESTDIR" >> ~/.bash_profile
	else
		log "Looks like you're not using bash. Please add this to you shell's profile:"
		echo $'\t'"export PATH=\$PATH:$DESTDIR"
		newline
	fi
fi

log "Pulling docker image..."

$DESTDIR/sr pull-image

log "Checking installation..."
newline

$DESTDIR/sr run echo -e "Welcome to Swifty Robot Environment" || err "Something is wrong :("

newline

cat <<HEREDOC
This environment will help you to compile Swift projects and libraries for Android.
For now, the environment is a prebuilt docker image containing the Swift compiler, 
Swift Package Manager, and also the Swift Runtime, Libdispatch and Foundation libraries. 
All ready to be deployed on an Android platform.

A set of tools will help you through the process of building and deploying Swift
applications and its dependencies.

Start exploring by loading the environment in your PATH:
\$ source ~/.bash_profile

and then by checking the available commands:
\$ sr help

We'd love to receive your feedback!
This is a very first version of a tool that can be better.
Help us to define the path to follow here:
https://github.com/gonzalolarralde/swifty-robot-environment/issues/new

Happy Swiftying!

HEREDOC

