#### swifty-robot-environment ####
#
# Version 0.5 (2017-04-01)
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
				--disable-build-tests \
				--prefix=$SWIFT_INSTALLATION_PATH/usr

		make
		make install

	popd

popd
