#### swifty-robot-environment ####
#
# Installs current NDK version and removes unused toolchains and platforms
#
# Version 0.2 (2016-09-23)
#
# Dependencies: ndk @ google/android
#

source .profile

mkdir ndk
wget https://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip -O ndk.zip
unzip ndk.zip -d ./ndk
rm ndk.zip

export NDK_DIR=`ls -d -1 ./ndk/* | head -1`

pushd $NDK_DIR
	pushd toolchains
		rm -r aarch64-linux-android-4.9 mips64el-linux-android-4.9 mipsel-linux-android-4.9 x86-4.9 x86_64-4.9
	popd

	pushd platforms
		rm -r android-9 android-12 android-13 android-14 android-15 android-17 android-18 android-19 android-22 android-23 android-24
	popd
popd

echo 'export NDK="'`realpath $NDK_DIR`'"' >> .profile
