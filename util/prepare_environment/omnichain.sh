#!/bin/bash -x
#
# Second stage of building franken-toolchain for Ubuntu and macOS
# Build Android toolchain on Linux using the swifty-robot scripts
# then copy the entire swifty-robot tree to macOS. Now remove the
# swift-source/build directory and run 050_build_swift_android.sh
# again until it fails but it will have generated a swiftc binary
# for macOS then run this script to clean the swift-install tree.
#

cd "$(dirname "$0")"

mkdir -p swift-install/usr/Darwin
cp $ANDROID_HOME/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/{arm-linux-androideabi/bin/ld.gold,lib/gcc/arm-linux-androideabi/4.9.x/armv7-a/libgcc.a} swift-install/usr/Darwin
cp swift-source/build/Ninja-ReleaseAssert/swift-macosx-x86_64/bin/swift swift-install/usr/Darwin/swiftc

rm -rf swift-install/usr/bin
mkdir swift-install/usr/bin
ln -s /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift swift-install/usr/bin
ln -s swift swift-install/usr/bin/swift-autolink-extract

rm -rf swift-install/{usr/{include,libexec,local,share,lib/{*.a,*.so*,lldb,python2.7,swift_static,swift/{android/{CoreFoundation,armv7/glibc.modulemap~},clang/lib,linux,migrator,openssl,pm,usr}}},rebuild_foundation.sh,swift-android-gradle}

tar cfvz android_toolchain.tgz swift-install/

ls -l android_toolchain.tgz
md5 android_toolchain.tgz
