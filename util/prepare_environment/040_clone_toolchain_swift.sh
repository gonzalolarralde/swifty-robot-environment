#### swifty-robot-environment ####
#
# Get last swift and components repositories cloned
#
# Version 0.2 (2016-12-30)
#
# Dependencies: swift @ github/apple
#               approved_prs @ pick.ly
#               api @ github
#

source .profile

export APPROVED_PRS_URL=http://pick.ly/swiftyrobot/util/approved_prs.php
export GIT_URL_SWIFT=https://github.com/SwiftJava/swift.git

function check_pr_mergeability {
        curl -s https://api.github.com/repos/$1/$2/pulls/$3 | python -c 'import json, sys; j = json.loads(sys.stdin.read()); exit(0 if (j["state"] == "open" and j["mergeable"]) else 127)' > /dev/null 2> /dev/null
}

function fetch_pr {
        curl -s https://patch-diff.githubusercontent.com/raw/$1/$2/pull/$3.patch > pr_$3.patch
}

function apply_pr {
        echo -n "Applying $1/$2#$3 from to $2: "
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
git clone $GIT_URL_SWIFT swift-source/swift

pushd swift-source
	swift/utils/update-checkout --clone

	#apply_approved_prs
	cd clang       && git checkout e352443ae3832ddb64f071fe2f9d201f25ec7c40 && cd - &&
	cd cmark       && git checkout d875488a6a95d5487b7c675f79a8dafef210a65f && cd - &&
	cd compiler-rt && git checkout e0e24585ee1c8941a13465a34baa5cc0e66a705c && cd - &&
	cd llbuild     && git checkout 1370ca71339b0c2a01d660834f83f22c94845633 && cd - &&
	cd lldb        && git checkout a3a5134d7f083f643d09316d41094802cc117db9 && cd - &&
	cd ninja       && git checkout 256bf897b85e35bc90294090ad39b5214eb141fb && cd - &&
	cd swift                          && git checkout android-toolchain-1.0 && cd - &&
	rm -rf llvm                       && git clone https://github.com/SwiftJava/swift-llvm.git &&
	mv swift-llvm llvm && cd llvm     && git checkout android-toolchain-1.0.3 && cd - &&
	rm -rf swift-corelibs-libdispatch && git clone https://github.com/SwiftJava/swift-corelibs-libdispatch.git &&
	cd swift-corelibs-libdispatch     && git checkout android-toolchain-1.0 && cd - &&
	rm -rf swift-corelibs-foundation  && git clone https://github.com/SwiftJava/swift-corelibs-foundation.git &&
	cd swift-corelibs-foundation      && git checkout android-toolchain-1.0.2 && cd - &&
	rm -rf swift-corelibs-xctest      && git clone https://github.com/SwiftJava/swift-corelibs-xctest.git &&
	cd swift-corelibs-xctest          && git checkout android-toolchain-1.0 && cd - &&
	cd swift-integration-tests        && git checkout 1d5d149f7aab027c9a7dccd19c0680bf36761a68 && cd - &&
	cd swift-xcode-playground-support && git checkout 05737c49f04b9089392b599ad529ab91c7119a75 && cd - &&
	cd swiftpm                        && git checkout f2ca05b0f2e7ae817e82dc88f9410a17e17a184a && cd -

popd

echo 'export SWIFT_ANDROID_SOURCE="'`realpath ./swift-source`'"' >> .profile
