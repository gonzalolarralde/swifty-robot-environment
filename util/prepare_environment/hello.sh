

swift-install/usr/bin/swiftc \
    -tools-directory /usr/android/ndk/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/bin \
    -target armv7-none-linux-androideabi \
    -sdk /usr/android/ndk/platforms/android-21/arch-arm \
    -L /usr/android/ndk/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a \
    -L /usr/android/ndk/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/lib/gcc/arm-linux-androideabi/4.9.x \
    hello.swift -Xlinker -pie
