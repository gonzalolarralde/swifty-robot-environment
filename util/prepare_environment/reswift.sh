
#. .profile

cd swift-source/swift-corelibs-libdispatch/ &&
make distclean; cd - &&
bash 050_build_swift_android.sh &&
bash 060_build_corelibs_libdispatch.sh &&
bash 080_build_corelibs_foundation.sh &&
#cd swift-install/usr/lib/swift/android &&
#rpl -R -e libicu libscu lib*.so && cd - &&
#cp $LIBICONV_ANDROID/armeabi-v7a/libicu{uc,i18n,data} $NDK/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a/libc++_shared.so . && cd -
./t.sh g

