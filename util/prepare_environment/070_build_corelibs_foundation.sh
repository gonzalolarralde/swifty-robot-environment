#### swifty-robot-environment ####
#
# Builds modified version of build_corelibs_foundation by John Holdsworth (tw:@Injection4Xcode)
# Waiting for (#622) (https://github.com/apple/swift-corelibs-foundation/pull/622)
#
# Version 0.7 (2016-12-30)
#
# Dependencies: swift @ github/apple
#               swift-corelibs-libdispatch @ github/apple
#               zlib @ zlib.net
#               openssl @ openssl.org
#               curl @ github/curl
#               libxml2 @ git/gnome
#               swift-corelibs-foundation @ github/apple
#

source .profile

export DOWNLOAD_URL_ZLIB=http://zlib.net/zlib-1.2.8.tar.gz
export DOWNLOAD_URL_OPENSSL=https://www.openssl.org/source/openssl-1.0.2-latest.tar.gz
export GIT_URL_CURL=https://github.com/curl/curl.git
export GIT_URL_LIBXML2=git://git.gnome.org/libxml2
export GIT_URL_CORELIBS_FOUNDATION=https://github.com/apple/swift-corelibs-foundation.git

export TOOLCHAIN=`realpath ./android-standalone-toolchain`
export SYSROOT=$TOOLCHAIN/sysroot

# Create Android toolchain
$NDK/build/tools/make_standalone_toolchain.py --api 21 --arch arm --stl libc++ --install-dir $TOOLCHAIN --force -v
export PATH=$TOOLCHAIN/bin:$PATH

pushd $TOOLCHAIN/sysroot

	# Set cross-compilation env variables (taken from https://gist.github.com/VictorLaskin/1c45245d4cdeab033956)
	
	export CC=arm-linux-androideabi-clang
	export CXX=arm-linux-androideabi-clang++
	export AR=arm-linux-androideabi-ar
	export AS=arm-linux-androideabi-as
	export LD=arm-linux-androideabi-ld
	export RANLIB=arm-linux-androideabi-ranlib
	export NM=arm-linux-androideabi-nm
	export STRIP=arm-linux-androideabi-strip
	export CHOST=arm-linux-androideabi
	export CXXFLAGS="-std=c++14 -Wno-error=unused-command-line-argument"

	# Create destination directories

	mkdir downloads src

	# Download and compile zlib

	mkdir src/zlib
	wget $DOWNLOAD_URL_ZLIB -O downloads/zlib.tar.gz
	tar -xvf downloads/zlib.tar.gz -C src/zlib --strip-components=1

	pushd src/zlib
		./configure --static --prefix=$SYSROOT/usr
		make
		make install
	popd

	# Download and compile openssl

	mkdir src/openssl
	wget $DOWNLOAD_URL_OPENSSL -O downloads/openssl.tar.gz # 1.0.2h was the current version at the moment where this script has been written 
	tar -xvf downloads/openssl.tar.gz -C src/openssl --strip-components=1

	pushd src/openssl

		if [ ! -f /usr/local/bin/perl ]; then
			ln -s /usr/bin/perl /usr/local/bin/perl
		fi

		export CPPFLAGS="-mthumb -mfloat-abi=softfp -mfpu=vfp -march=armv7  -DANDROID"
		# -mandroid option seems to be only for gcc compilers. It was causing troubles with clang
		sed "s/-mandroid //g" Configure > Configure.new && chmod +x Configure.new 

		./Configure.new android-armv7 no-asm no-shared zlib --static --with-zlib-include=$SYSROOT/usr --with-zlib-lib=$SYSROOT/usr --prefix=$SYSROOT/usr --sysroot=$SYSROOT

		pushd crypto
			make buildinf.h
		popd

		make depend build_crypto build_ssl -j 4

		# This subproject is causing issues with install_sw target. We don't need the binaries.
		rm -r apps

		# Create fake empty files to complete installation succesfully
		touch libcrypto.pc libssl.pc openssl.pc

		make install_sw
	popd

	# Download and compile curl

	git clone $GIT_URL_CURL src/curl

	pushd src/curl
		autoreconf -i
		./configure --host=arm-linux-androideabi --enable-shared --disable-static --disable-dependency-tracking --with-zlib=$SYSROOT/usr --with-ssl=$SYSROOT/usr --without-ca-bundle --without-ca-path --enable-ipv6 --enable-http --enable-ftp --disable-file --disable-ldap --disable-ldaps --disable-rtsp --disable-proxy --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher --disable-sspi --disable-manual --target=arm-linux-androideabi --build=x86_64-unknown-linux-gnu --prefix=$SYSROOT/usr
		make
		make install
	popd

	# Download and compile libxml2

	git clone $GIT_URL_LIBXML2 src/libxml2

	pushd src/libxml2
		autoreconf -i
		./configure --with-sysroot=$SYSROOT --with-zlib=$SYSROOT/usr --prefix=$SYSROOT/usr --host=$CHOST --without-lzma --disable-static --enable-shared --without-http --without-html --without-ftp
		make libxml2.la
		make install-libLTLIBRARIES

		pushd include
			make install
		popd
	popd

	# Clean env variables

	export LDFLAGS=
	export CC=
	export CXX=
	export AR=
	export AS=
	export LD=
	export RANLIB=
	export NM=
	export STRIP=
	export CHOST=
	export CXXFLAGS=
	export CPPFLAGS=
	
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
			ln -s $SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64/lib/swift/android/armv7 $SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64/lib/swift/linux/armv7

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
				./configure \
					Release \
					--target=armv7-none-linux-androideabi \
					-DXCTEST_BUILD_DIR=$SWIFT_ANDROID_BUILDPATH/xctest-linux-x86_64 \
					-DLIBDISPATCH_SOURCE_DIR=$SWIFT_ANDROID_SOURCE/swift-corelibs-libdispatch \
					-DLIBDISPATCH_BUILD_DIR=$SWIFT_ANDROID_BUILDPATH/libdispatch-linux-x86_64

			# Prepend SYSROOT env variable to ninja.build script
			# SYSROOT is not being passed from build.py / script.py to the ninja file yet
			echo "SYSROOT=$SYSROOT" > build.ninja.new
			cat build.ninja >> build.ninja.new
			rm build.ninja
			mv build.ninja.new build.ninja

			/usr/bin/ninja

			# Undo those nasty changes
			rm $SWIFT_ANDROID_BUILDPATH/swift-linux-x86_64/lib/swift/linux/armv7
		popd

	popd

popd

export SYSROOT=
export TOOLCHAIN=
