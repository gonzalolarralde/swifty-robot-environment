#!/bin/bash
#
# Script to setup Ubuntu 16.0.4 environment to use Android toolchain
#

export ANDROID_HOME=${ANDROID_HOME:-~/Android}

cd $(dirname $0)
mkdir -p $ANDROID_HOME &&
sudo mkdir -p /usr/java /usr/android &&
sudo chmod 777 /usr/java /usr/android &&
sudo apt-get -y update && sudo apt-get install -y \
	git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools \
	libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev \
	libncurses5-dev pkg-config libblocksruntime-dev libcurl4-openssl-dev \
	autoconf automake libtool curl wget unzip lib32stdc++6 lib32z1 rpl &&

cat <<EOF &&

*************************************************************************

Browse to http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
and download and install a Java SDK by extracting the zip file to /usr/java.

Browse to https://developer.android.com/studio/index.html and scroll down
to the section "Get just the command line tools" and downlaod the Linux
sdk-tools-linux-NNNNNNN.zip. Extract the archive into $ANDROID_HOME.

Press return when you've done this.
EOF

read X &&

export JAVA_HOME="${JAVA_HOME:-$(echo /usr/java/*)}" &&

$ANDROID_HOME/tools/bin/sdkmanager --licenses &&
$ANDROID_HOME/tools/bin/sdkmanager "ndk-bundle" "platforms;android-25" "build-tools;25.0.3" "platform-tools" &&

sudo ln -s $ANDROID_HOME/ndk-bundle /usr/android/ndk
sudo ln -s ndk/platforms/android-21/arch-arm /usr/android/platform
sudo mv /usr/bin/ld.gold /usr/bin/ld.gold.save
sudo bash -c 'cat >/usr/bin/ld.gold' cat <<EOF &&
#!/bin/bash

if [[ "$*" =~ "androideabi" ]]; then
        /usr/android/ndk/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/bin/ld.gold "$@"
else
        /usr/bin/ld.gold.save "$@"
fi

exit $?
EOF

sudo chmod 755 /usr/bin/ld.gold &&

cat <<EOF >>~/.bashrc &&

# Changes for Android Swift toolchain
export JAVA_HOME="$JAVA_HOME"
export ANDROID_HOME="$ANDROID_HOME"
export PATH="$PWD/usr/bin:\$HOME/Android/platform-tools:\$PATH"
EOF

cat <<EOF

Instalation complete. type source ~/.bashrc to begin.

An example project is available at:
https://github.com/SwiftJava/swift-android-samples

To build this project you must first install the gradle plugin:
https://github.com/SwiftJava/swift-android-gradle

EOF
