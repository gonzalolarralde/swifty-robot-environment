#!/bin/bash
#### swifty-robot-environment ####
#
# Rebuilds foundation from source
#
# Version 0.1 (2017-01-25xs)
#
# Dependencies: swift android toolchain + android NDK linked to /usr/android/ndk
#

export SWIFT_INSTALLATION_PATH=$(dirname $(dirname $(dirname $(which swiftc))))
export SYSROOT=$SWIFT_INSTALLATION_PATH
export SWIFT_ANDROID_BUILDPATH=/tmp
export NDK=/usr/android/ndk

git clone http://apple/swift/swift-corelibs-foundation

	# Build foundation
	# Remove default foundation implementation and fetch the version with android support

pushd swift-corelibs-foundation

	rm -rf $SWIFT_INSTALLATION_PATH/usr/lib/swift/CoreFoundation

	env \
		CLANG="$SWIFT_INSTALLATION_PATH/usr/bin/clang" \
		SWIFT="$SWIFT_INSTALLATION_PATH/usr/bin/swift" \
		SWIFTC="$SWIFT_INSTALLATION_PATH/usr/bin/swiftc" \
		SDKROOT="$SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64.x" \
		BUILD_DIR="$SWIFT_ANDROID_BUILDPATH/foundation-linux-x86_64" \
		DSTROOT="/" \
		PREFIX="/usr/" \
		CFLAGS="-DDEPLOYMENT_TARGET_ANDROID -DDEPLOYMENT_ENABLE_LIBDISPATCH --sysroot=$NDK/platforms/android-21/arch-arm -I$SWIFT_INSTALLATION_PATH/usr/lib/swift -I$LIBICONV_ANDROID/armeabi-v7a/include.x -I$SWIFT_INSTALLATION_PATH/usr/lib/swift/clang/include -I${SDKROOT}/lib/swift -I$NDK/sources/android/support/include -I$PWD/closure" \
		SWIFTCFLAGS="-DDEPLOYMENT_TARGET_ANDROID -DDEPLOYMENT_ENABLE_LIBDISPATCH -I$NDK/platforms/android-21/arch-arm/usr/include -L /usr/local/lib/swift/android -I /usr/local/lib/swift/android/armv7 -I$SWIFT_INSTALLATION_PATH/usr/lib/swift" \
		LDFLAGS="-fuse-ld=gold --sysroot=$NDK/platforms/android-21/arch-arm -L$NDK/platforms/android-21/arch-arm/usr/lib -L$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/lib/gcc/arm-linux-androideabi/4.9.x -L$LIBICONV_ANDROID/armeabi-v7a -L/usr/local/lib/swift/android -L$SYSROOT/usr/lib -ldispatch " \
		SDKROOT=$SYSROOT/usr \
		./configure \
			Debug \
			--target=armv7-none-linux-androideabi \
			--sysroot=$NDK/platforms/android-21/arch-arm \
			-DXCTEST_BUILD_DIR=$SWIFT_ANDROID_BUILDPATH/xctest-linux-x86_64 \
			-DLIBDISPATCH_SOURCE_DIR=$SWIFT_ANDROID_SOURCE/swift-corelibs-libdispatch \
			-DLIBDISPATCH_BUILD_DIR=$SWIFT_ANDROID_SOURCE/swift-corelibs-libdispatch

	# Prepend SYSROOT env variable to ninja.build script
	# SYSROOT is not being passed from build.py / script.py to the ninja file yet
	echo "SYSROOT=$SYSROOT" > build.ninja.new
	cat build.ninja >> build.ninja.new
	sed -e 's@`${PKG_CONFIG} icu-uc icu-i18n --libs`@-lscui18n -lscuuc -lscudata@' <build.ninja.new >build.ninja

	/usr/bin/ninja
			
	# There's no installation script for foundation yet, so the installation needs to be done manually.
	# Apparently the installation for the main script is in swift repo.
	cp $SWIFT_ANDROID_BUILDPATH/foundation-linux-x86_64/Foundation/libFoundation.so $SWIFT_INSTALLATION_PATH/usr/lib/swift/android/
	cp $SWIFT_ANDROID_BUILDPATH/foundation-linux-x86_64/Foundation/Foundation.swift* $SWIFT_INSTALLATION_PATH/usr/lib/swift/android/armv7/
	cp -r $SWIFT_ANDROID_BUILDPATH/foundation-linux-x86_64/Foundation/usr/lib/swift/CoreFoundation $SWIFT_INSTALLATION_PATH/usr/lib/swift

popd
