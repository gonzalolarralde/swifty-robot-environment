#### swifty-robot-environment ####
#
# Builds libiconv and libicu using @SwiftAndroid's script
#
# Version 0.2 (2018-12-30)
#
# Dependencies: libiconv-libicu-android @ github/SwiftAndroid
#

source .profile

git clone https://github.com/SwiftAndroid/libiconv-libicu-android.git libiconv-libicu-android

pushd ./libiconv-libicu-android 

    export PATH="$NDK:$PATH"
    export LIBSUFFIX="swift"
    ./build-swift.sh

popd

echo 'export LIBICONV_ANDROID="'`realpath ./libiconv-libicu-android`'"' >> .profile
