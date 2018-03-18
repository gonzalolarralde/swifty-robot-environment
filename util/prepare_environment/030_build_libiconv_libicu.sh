#### swifty-robot-environment ####
#
# Builds libiconv and libicu using @SwiftAndroid's script
#
# Version 0.1 (2016-09-12)
#
# Dependencies: libiconv-libicu-android @ github/SwiftAndroid
#

source .profile

git clone https://github.com/SwiftAndroid/libiconv-libicu-android.git libiconv-libicu-android

pushd ./libiconv-libicu-android 

    export PATH="$NDK:$PATH"
    export LIBSUFFIX="swift"
    ./build.sh

popd

echo 'export LIBICONV_ANDROID="'`realpath ./libiconv-libicu-android`'"' >> .profile
