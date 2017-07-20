### Helpers ###

function sr_err {
    echo \> $'\033[0;31m'$*$'\033[0m' >&2
    exit 1
}

function sr_call_docker {
    /usr/bin/env docker > /dev/null 2> /dev/null || sr_err "Please install docker. "$'\n\t'"Ubuntu: https://docs.docker.com/engine/installation/linux/ubuntulinux/"$'\n\t'"Mac: https://docs.docker.com/docker-for-mac/"
    /usr/bin/env docker ps > /dev/null 2> /dev/null || sr_err "Please start docker."
    
    /usr/bin/env docker $@
}

### Built-in commands ###

function sr_version {
    echo "Swifty Robot Environment v$SR_VERSION"
    if [[ $1 != "short" ]]; then
        echo # Add swift + libs version in the future
    fi
}

function sr_help {
    cat <<HEREDOC
$(sr_version short)

Built-in commands:

    help - Shows this help message
    self-update - Get the latest version of Swifty Robot Environment
    pull-image - Pull the docker image required for the current version
    run - Execute an arbitrary command in the environment
    shell - Create a temporary container and start a shell

Commands:
$(sr_command_list)

HEREDOC
}

function sr_self_update {
    /usr/bin/env curl -s $SR_UPDATE_URL | /usr/bin/env bash -s update $SR_VERSION 
}

function sr_pull_image {
    sr_call_docker pull $SR_IMAGE
}

function sr_run {
	sr_call_docker run --rm -v /:$SR_HOST_FS -w="$SR_HOST_FS`pwd`" $SR_IMAGE $@
}

function sr_shell {
    sr_call_docker run --rm -ti $SR_IMAGE /bin/bash -l $@
}

### Commands ###

function sr_command_desc {
	# Ugly as hell. This needs to get improved.
	unset $SR_COMMAND_DESC
	eval $( cat $SR_DIR/commands/$1 | grep "SR_COMMAND_DESC" )
	if [[ "$SR_COMMAND_DESC" ]]; then
		echo " - $SR_COMMAND_DESC"
	else
		echo
	fi
}

function sr_command_list {
    ls -1 $SR_DIR/commands/ | while read COMMAND; do
        echo -n $'    '$COMMAND
        sr_command_desc $COMMAND
    done
}

function sr_has_command {
    [[ -f $SR_DIR/commands/$1 ]]
}

function sr_run_command {
    sr_run "$SR_HOST_FS$SR_DIR/commands/$1" ${@:2}
}
