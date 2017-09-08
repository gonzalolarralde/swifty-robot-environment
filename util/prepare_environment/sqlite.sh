#!/bin/bash

source .profile
export TOOLCHAIN=`realpath ./android-standalone-toolchain`
export PATH=$TOOLCHAIN/bin:$PATH

pushd sqlite-autoconf-*

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
	export ARCH_FLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
	export ARCH_LINK="-march=armv7-a -Wl,--fix-cortex-a8"
	export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing "
	export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -frtti -fexceptions -std=c++11 -Wno-error=unused-command-line-argument "
	export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing "
	export LDFLAGS=" ${ARCH_LINK} "

	./configure --host=arm-linux-androideabi --enable-shared --disable-static --disable-dependency-tracking --with-zlib=$SYSROOT/usr --with-ssl=$SYSROOT/usr --without-ca-bundle --without-ca-path --enable-ipv6 --enable-http --enable-ftp --disable-file --disable-ldap --disable-ldaps --disable-rtsp --disable-proxy --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher --disable-sspi --disable-manual --target=arm-linux-androideabi --build=x86_64-unknown-linux-gnu --prefix=$SYSROOT/usr

	make

	mkdir -p ../swift-android-sqlite/libs
	cp sqlite3.h ../swift-android-sqlite
	cat <<MAP >../swift-android-sqlite/module.modulemap
module sqlite3 [system] {
    header "sqlite3.h"
    link "sqlite3"
    export *
}
MAP
	
    	cp .libs/libsqlite3.so ../swift-android-sqlite/libs
	$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/bin/strip ../swift-android-sqlite/libs/libsqlite3.so	

popd

pushd swift-source/swift-corelibs-xctest
	~/.gradle/scripts/swift-build.sh -c release -Xswiftc -module-link-name -Xswiftc XCTest
	cp ./.build/x86_64-unknown-linux/release/libXCTest.so ../../swift-install/usr/lib/swift/android/libXCTest.so
	cp ./.build/x86_64-unknown-linux/release/XCTest.swift{module,doc} ../../swift-install/usr/lib/swift/android/armv7/
popd

tar cfvz ~/update.tgz swift-install/{licenses,README.html,setup.sh,usr/{Linux,lib/swift/android/{lib*.so,armv7/*.swift*}}} swift-source/swift/{lib/{Driver/ToolChains.cpp,Parse/ParseIfConfig.cpp},stdlib/public/{runtime/ImageInspectionELF.cpp,Platform/tgmath.swift.gyb}}

#tar cfvz ~/update.tgz swift-install/{licenses,README.html,setup.sh,usr/{Linux,lib/swift}} swift-source/swift/{lib/{Driver/ToolChains.cpp,Parse/ParseIfConfig.cpp},stdlib/public/{runtime/ImageInspectionELF.cpp,Platform/tgmath.swift.gyb}}


