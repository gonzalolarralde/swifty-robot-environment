#### swifty-robot-environment ####
#
# Builds modified version of build_corelibs_foundation by John Holdsworth (tw:@Injection4Xcode)
#
# Version 0.8 (2017-04-01)
#
# Dependencies: swift @ github/apple
#               swift-corelibs-libdispatch @ github/apple
#               openssl @ openssl.org
#               curl @ github/curl
#               libxml2 @ git/gnome
#               swift-corelibs-foundation @ github/apple
#

source .profile

export TOOLCHAIN=`realpath ./android-standalone-toolchain`
export SYSROOT=$TOOLCHAIN/sysroot
export PATH=$TOOLCHAIN/bin:$PATH

pushd $TOOLCHAIN/sysroot

	# Move dispatch public and private headers to the directory foundation is expecting to get it
	
	mkdir -p $SYSROOT/usr/include/dispatch
	cp $SWIFT_ANDROID_SOURCE/swift-corelibs-libdispatch/dispatch/*.h $SYSROOT/usr/include/dispatch
	cp $SWIFT_ANDROID_SOURCE/swift-corelibs-libdispatch/private/*.h $SYSROOT/usr/include/dispatch
	
	# Build foundation
	# Remove default foundation implementation and fetch the version with android support

	pushd $SWIFT_ANDROID_SOURCE

		# rm -r swift-corelibs-foundation
		# git clone $GIT_URL_CORELIBS_FOUNDATION swift-corelibs-foundation

		pushd swift-corelibs-foundation

			# Libfoundation script is not completely prepared to handle cross compilation yet.
			ln -s $SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64/lib/swift $SYSROOT/usr/lib/

			# Search path for curl seems to be wrong in foundation
			ln -s $SYSROOT/usr/include/curl $SYSROOT/usr/include/curl/curl

			env \
				SWIFTC="$SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64/bin/swiftc" \
				CLANG="$SWIFT_ANDROID_BUILDPATH/llvm-linux-x86_64/bin/clang" \
				SWIFT="$SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64/bin/swift" \
				SDKROOT="$SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64" \
				BUILD_DIR="$SWIFT_ANDROID_BUILDPATH/foundation-linux-x86_64" \
				DSTROOT="/" \
				PREFIX="/usr/" \
				CFLAGS="-DDEPLOYMENT_TARGET_ANDROID -DDEPLOYMENT_ENABLE_LIBDISPATCH --sysroot=$NDK/platforms/android-21/arch-arm -I$LIBICONV_ANDROID/armeabi-v7a/include -I${SDKROOT}/lib/swift -I$NDK/sources/android/support/include -I$SYSROOT/usr/include -I$SWIFT_ANDROID_SOURCE/swift-corelibs-foundation/closure" \
				SWIFTCFLAGS="-DDEPLOYMENT_TARGET_ANDROID -DDEPLOYMENT_ENABLE_LIBDISPATCH -I$NDK/platforms/android-21/arch-arm/usr/include -L /usr/local/lib/swift/android -I /usr/local/lib/swift/android/armv7" \
				LDFLAGS="-fuse-ld=gold --sysroot=$NDK/platforms/android-21/arch-arm -L$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/lib/gcc/arm-linux-androideabi/4.9.x -L$LIBICONV_ANDROID/armeabi-v7a -L/usr/local/lib/swift/android -L$SYSROOT/usr/lib -ldispatch " \
				SDKROOT=$SYSROOT/usr \
				./configure \
					Release \
					--target=armv7-none-linux-androideabi \
					--sysroot=$SYSROOT \
					-DXCTEST_BUILD_DIR=$SWIFT_ANDROID_BUILDPATH/xctest-linux-x86_64 \
					-DLIBDISPATCH_SOURCE_DIR=$SWIFT_ANDROID_SOURCE/swift-corelibs-libdispatch \
					-DLIBDISPATCH_BUILD_DIR=$SWIFT_ANDROID_SOURCE/swift-corelibs-libdispatch

			# Prepend SYSROOT env variable to ninja.build script
			# SYSROOT is not being passed from build.py / script.py to the ninja file yet
			echo "SYSROOT=$SYSROOT" > build.ninja.new
			cat build.ninja >> build.ninja.new
			rm build.ninja
			mv build.ninja.new build.ninja

			/usr/bin/ninja
			
			# There's no installation script for foundation yet, so the installation needs to be done manually.
			# Apparently the installation for the main script is in swift repo.
			cp $SWIFT_ANDROID_BUILDPATH/foundation-linux-x86_64/Foundation/libFoundation.so $SWIFT_INSTALLATION_PATH/usr/lib/swift/android/
			cp $SWIFT_ANDROID_BUILDPATH/foundation-linux-x86_64/Foundation/Foundation.swift* $SWIFT_INSTALLATION_PATH/usr/lib/swift/android/armv7/
			cp $SYSROOT/usr/lib/libxml2.* $SWIFT_INSTALLATION_PATH/usr/lib/swift/android/
			cp $SYSROOT/usr/lib/libcurl.* $SWIFT_INSTALLATION_PATH/usr/lib/swift/android/	
			cp -r $SWIFT_ANDROID_BUILDPATH/foundation-linux-x86_64/Foundation/usr/lib/swift/CoreFoundation $SWIFT_INSTALLATION_PATH/usr/lib/swift

			# Undo those nasty changes
			rm $SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64/lib/swift/linux/armv7

			# prep install so it can be used to build foundation
			cp -r $SYSROOT/src/libxml2/include/libxml $SWIFT_INSTALLATION_PATH/usr/lib/swift
			mkdir -p $SWIFT_INSTALLATION_PATH/usr/lib/swift/openssl
			cp $SYSROOT/src/openssl/include/openssl/* $SWIFT_INSTALLATION_PATH/usr/lib/swift/openssl
			cp -r $SYSROOT/src/curl/include/curl $SWIFT_INSTALLATION_PATH/usr/lib/swift
			cp -r $LIBICONV_ANDROID/armeabi-v7a/include/unicode $SWIFT_INSTALLATION_PATH/usr/lib/swift
			cp $SWIFT_ANDROID_BUILDPATH/llvm-linux-x86_64/bin/clang $SWIFT_INSTALLATION_PATH/usr/bin

			mkdir -p $SWIFT_INSTALLATION_PATH/licenses
			cp $SWIFT_ANDROID_SOURCE/swift/LICENSE.txt $SWIFT_INSTALLATION_PATH/licenses/SWIFT
			cp $SWIFT_ANDROID_SOURCE/swift-corelibs-libdispatch/LICENSE $SWIFT_INSTALLATION_PATH/licenses/DISPATCH
			cp $SWIFT_ANDROID_SOURCE/swift-corelibs-foundation/LICENSE $SWIFT_INSTALLATION_PATH/licenses/FOUNDATION
			cp $SWIFT_ANDROID_SOURCE/swiftpm/LICENSE.txt $SWIFT_INSTALLATION_PATH/licenses/SWIFTPM
			cp $SWIFT_ANDROID_SOURCE/clang/LICENSE.TXT $SWIFT_INSTALLATION_PATH/licenses/CLANG
			cp $SWIFT_ANDROID_SOURCE/llvm/LICENSE.TXT $SWIFT_INSTALLATION_PATH/licenses/LLVM
			cp $SWIFT_ANDROID_SOURCE/lldb/LICENSE.TXT $SWIFT_INSTALLATION_PATH/licenses/LLDB
			cp $SWIFT_ANDROID_SOURCE/llbuild/LICENSE.txt $SWIFT_INSTALLATION_PATH/licenses/LLBUILD
			cp $SYSROOT/src/curl/COPYING $SWIFT_INSTALLATION_PATH/licenses/CURL
			cp $SYSROOT/src/openssl/LICENSE $SWIFT_INSTALLATION_PATH/licenses/OPENSSL
			cp $SYSROOT/src/libxml2/README $SWIFT_INSTALLATION_PATH/licenses/LIBXML

			cp ../../{{setup_ubuntu_client,rebuild_foundation}.sh,LICENSE} $SWIFT_INSTALLATION_PATH

		popd

	popd

popd

export SYSROOT=
export TOOLCHAIN=
