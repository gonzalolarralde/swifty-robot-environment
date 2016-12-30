function sr_run {
	docker run --rm -v /:$HOST_FS -w="$HOST_FS`pwd`" $SWIFTY_ROBOT_IMAGE $@
}

function sr_shell {
	docker run --rm -ti $SWIFTY_ROBOT_IMAGE /bin/bash
}

function sr_has_command {
	[[ -f $DIR/commands/$1 ]]
}

function sr_run_command {
	sr_run "$HOST_FS$DIR/commands/$1" ${@:2}
	exit $?
}
