#!/bin/bash
#
# Runs swift-android-gradle/src/main/scripts/create_scripts.sh to initialise
# toolchain and install gradle plugin used for Android Studio builds.
#
# Example application: https://github.com/SwiftJava/swift-android-kotlin
#

cd "$(dirname "$0")" &&

if [[ ! -d swift-android-gradle || "$1" == "-f" ]]; then
    rm -rf swift-android-gradle
    git clone https://github.com/SwiftJava/swift-android-gradle
fi &&

cd swift-android-gradle && ./gradlew install
