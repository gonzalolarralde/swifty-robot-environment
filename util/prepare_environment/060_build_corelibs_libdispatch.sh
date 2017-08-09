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
			CFLAGS="-DTRASHIT=''" \
			LIBS="-L/tmp/placeholder" \
			./configure \
				--with-swift-toolchain="$SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64" \
				--with-build-variant=release \
				--enable-android \
				--host=arm-linux-androideabi \
				--with-android-ndk=$NDK \
				--with-android-api-level=21 \
				--disable-build-tests \
				--prefix=$SWIFT_INSTALLATION_PATH/usr

		sed -ie "s@-L/tmp/placeholder@-L$SWIFT_INSTALLATION_PATH/usr/lib/swift/android -lswiftCore -L$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/lib/armv7-a -latomic@" src/Makefile

		make
		make install

	popd

popd
