
export PATH=$PWD/swift-install/usr/bin:$PATH

if [ "$1" != "" ]; then
	 ~/.gradle/scripts/swiftc-android.sh t.swift -S -o a.s
fi

'/home/johnno/swifty-robot-environment/util/prepare_environment/ndk/android-ndk-r14b/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-as' a.s -o a.o

swiftc a.o -target armv7-none-linux-androideabi -sdk swift-install/ndk-android-21 -Xlinker -Lswift-install/usr/lib/swift/android -Xlinker -lswiftCore -Xlinker -L/home/johnno/swifty-robot-environment/util/prepare_environment/ndk/android-ndk-r14b/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/lib/gcc/arm-linux-androideabi/4.9.x -Xlinker -lgcc -Xlinker -lc -Xlinker -pie -Xlinker --dynamic-linker=/system/bin/linker -o t -tools-directory swift-install/usr/$ARCH

adb push t /data/local/tmp
adb shell LD_LIBRARY_PATH=/data/local/tmp /data/local/tmp/t
