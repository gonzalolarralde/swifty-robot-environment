#### swifty-robot-environment ####
#
# Get last swift and components repositories cloned
#
# Version 0.3 (2017-07-19)
#
# Dependencies: swift @ github/apple
#               approved_prs @ pick.ly
#               api @ github
#

source .profile

export APPROVED_PRS_URL=http://pick.ly/swiftyrobot/util/approved_prs.php
export GIT_URL_SWIFT=https://github.com/apple/swift.git

function check_pr_mergeability {
        curl -s https://api.github.com/repos/$1/$2/pulls/$3 | python -c 'import json, sys; j = json.loads(sys.stdin.read()); exit(0 if (j["state"] == "open" and j["mergeable"]) else 127)' > /dev/null 2> /dev/null
}

function fetch_pr {
        curl -s https://patch-diff.githubusercontent.com/raw/$1/$2/pull/$3.patch > pr_$3.patch
}

function apply_pr {
        echo -n "Applying $1/$2#$3 to $2: "
        if check_pr_mergeability $@; then

                fetch_pr $@

                pushd $2 > /dev/null
                        if git apply --check ../pr_$3.patch; then
                                git apply ../pr_$3.patch > /dev/null 2> /dev/null
                                echo "Done!"
                        else
                                echo "Path failed..."
                                exit 127
                        fi
                popd > /dev/null

                rm pr_$3.patch

        else
                echo "Closed or not mergeable..."
        fi
}

function apply_approved_prs {
        curl -s $APPROVED_PRS_URL | while read PR; do
                apply_pr $PR
        done
}

mkdir -p swift-source/swift
git clone $GIT_URL_SWIFT swift-source/swift # --depth 1 # --shallow-submodules

pushd swift-source
        swift/utils/update-checkout --clone # --skip-history
        apply_approved_prs
popd

echo 'export SWIFT_ANDROID_SOURCE="'`realpath ./swift-source`'"' >> .profile
