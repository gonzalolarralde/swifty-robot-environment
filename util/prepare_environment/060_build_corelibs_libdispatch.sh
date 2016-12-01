#### swifty-robot-environment ####
#
# Version 0.4 (2016-12-01)
#
# Dependencies: swift @ github/apple
#               swift-corelibs-libdispatch @ github/apple
#

source .profile

pushd $SWIFT_ANDROID_SOURCE

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

		# Resulting paths are not taking the architecture and OS correctly.
		mv /usr/local/lib/swift/linux/x86_64/Dispatch* /usr/local/lib/swift/android/armv7
		mv /usr/local/lib/swift/linux/libdispatch* /usr/local/lib/swift/android

	popd

popd
