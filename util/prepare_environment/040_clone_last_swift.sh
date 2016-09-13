#### swifty-robot-environment ####
#
# Get last swift and components repositories cloned
#
# Version 0.1 (2016-09-12)
#
# Dependencies: swift @ github/apple
#

source .profile

mkdir -p swift-source/swift
git clone https://github.com/apple/swift.git swift-source/swift

pushd swift-source
	swift/utils/update-checkout --clone
popd

echo 'export SWIFT_ANDROID_SOURCE="'`realpath ./swift-source`'"' >> .profile
