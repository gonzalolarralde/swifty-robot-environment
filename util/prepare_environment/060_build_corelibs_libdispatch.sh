#### swifty-robot-environment ####
#
# Builds modified version of build_corelibs_libdispatch. 
# Waiting for (#162) (https://github.com/apple/swift-corelibs-libdispatch/pull/162)
#
# Version 0.2 (2016-09-23)
#
# Dependencies: swift @ github/apple
#               swift-corelibs-libdispatch @ github/gonzalolarralde
#

source .profile

pushd $SWIFT_ANDROID_SOURCE

	# Remove default libdispatch implementation and fetch the version with android support
	rm -r swift-corelibs-libdispatch
	git clone https://github.com/gonzalolarralde/swift-corelibs-libdispatch -b android-support-rebased --recursive

	pushd swift-corelibs-libdispatch

		sh autogen.sh
		env \
			CC="$SWIFT_ANDROID_BUILDPATH/llvm-linux-x86_64/bin/clang" \
			CXX="$SWIFT_ANDROID_BUILDPATH/llvm-linux-x86_64/bin/clang++" \
			SWIFTC="$SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64/bin/swiftc" \
			./configure \
				--with-swift-toolchain="$SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64" \
				--with-build-variant=release \
				--enable-android \
				--host=arm-linux-androideabi \
				--with-android-ndk=$NDK \
				--with-android-api-level=21 \
				--disable-build-tests

		make
		make install

		mv /usr/local/lib/swift/android/ /usr/local/lib/swift/android
		mv /usr/local/lib/swift/android/x86_64/ /usr/local/lib/swift/android/armv7

	popd

popd
