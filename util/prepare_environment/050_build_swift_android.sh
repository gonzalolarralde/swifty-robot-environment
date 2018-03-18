#### swifty-robot-environment ####
#
# Builds Swift compiler for Android targets based on the last source cloned
#
# Version 0.5 (2017-04-01)
#
# Dependencies: ndk @ google/android
#               libiconv-libicu-android @ github/SwiftAndroid
#               swift @ github/apple
#

source .profile

export SWIFT_INSTALLATION_PATH="`realpath ./swift-install`"

mkdir -p $SWIFT_INSTALLATION_PATH

pushd $SWIFT_ANDROID_SOURCE/swift
    utils/build-script \
        -R \
        --android \
        --android-ndk $NDK \
        --android-api-level 21 \
        --android-icu-uc $LIBICONV_ANDROID/armeabi-v7a/ \
        --android-icu-uc-include $LIBICONV_ANDROID/armeabi-v7a/icu/source/common \
        --android-icu-i18n $LIBICONV_ANDROID/armeabi-v7a/ \
        --android-icu-i18n-include $LIBICONV_ANDROID/armeabi-v7a/icu/source/i18n \
        --libdispatch --install-libdispatch \
        --foundation --install-foundation \
        --llbuild --install-llbuild \
        --lldb --install-lldb \
        --swiftpm --install-swiftpm \
        --xctest --install-xctest \
        --install-swift \
        '--swift-install-components=autolink-driver;compiler;clang-builtin-headers;stdlib;swift-remote-mirror;sdk-overlay;dev' \
        --install-prefix=/usr --install-destdir=$SWIFT_INSTALLATION_PATH
popd

cp $LIBICONV_ANDROID/armeabi-v7a/libicuucswift.so $SWIFT_INSTALLATION_PATH/usr/lib/swift/android/
cp $LIBICONV_ANDROID/armeabi-v7a/libicudataswift.so $SWIFT_INSTALLATION_PATH/usr/lib/swift/android/
cp $LIBICONV_ANDROID/armeabi-v7a/libicui18nswift.so $SWIFT_INSTALLATION_PATH/usr/lib/swift/android/

export SWIFT_ANDROID_BUILDPATH="$SWIFT_ANDROID_SOURCE/build/Ninja-ReleaseAssert"
echo 'export SWIFT_ANDROID_BUILDPATH="'$SWIFT_ANDROID_BUILDPATH'"' >> .profile
echo 'export SWIFT_INSTALLATION_PATH="'$SWIFT_INSTALLATION_PATH'"' >> .profile
