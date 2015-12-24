#!/bin/bash
# Script will not work correctly yet
# And requires a keystore set up
# Player is not updated

export WORKSPACE=$PWD
export EASYDEV_ANDROID=$PWD
export NDK_ROOT=$WORKSPACE/android-ndk-r10e
export PATH=$PATH:$WORKSPACE/android-ndk-r10e:$WORKSPACE/android-sdk-linux/tools:$WORKSPACE/android-sdk-linux/build-tools/23.0.2/

git clone https://github.com/EasyRPG/Player.git

cd Player/builds/android

android update project --path "."
ndk-build -j3
ant clean
ant release
cd bin
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $WORKSPACE/easyrpg.keystore -storepass android SDLActivity-release-unsigned.apk nightly
zipalign 4 SDLActivity-release-unsigned.apk EasyRpgPlayerActivity.apk
