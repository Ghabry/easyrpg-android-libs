#!/bin/bash
# Script will not work correctly yet
# And requires a keystore set up
# Player is not updated

# Supported os : "darwin" ou "linux"
os=$1
darwin="darwin"
linux="linux"

export WORKSPACE=$(pwd)

export EASYDEV_ANDROID=$(pwd)

#export ndk_root
export NDK_ROOT=$WORKSPACE/android-ndk-r10e
export PATH=$PATH:$NDK_ROOT

#export sdk_root
export SDK_ROOT=WORKSPACE/android-sdk
export PATH=$PATH:$SDK_ROOT/tools:$SDK_ROOT/build-tools/23.0.2/	

export PATH_KEYSTORE=$(pwd)/../easyrpg.keystore

#git clone https://github.com/EasyRPG/Player.git

#cd Player/builds/android

#android update project --path "."
#ndk-build -j3
#ant clean
#ant release
#cd bin
#jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $WORKSPACE/easyrpg.keystore -storepass android SDLActivity-release-unsigned.apk nightly
#zipalign 4 SDLActivity-release-unsigned.apk EasyRpgPlayerActivity.apk


######################

cd Player
WORKSPACE=$(pwd)
# Clone of liblcf
mkdir -p lib
git clone https://github.com/EasyRPG/liblcf lib/liblcf
cd lib/liblcf
git pull
cd $WORKSPACE
cd builds/android
# Download of timidity
#git clone https://github.com/Ghabry/timidity_gus.git assets/timidity

#Pour connaitre les targets : 
#android list targets
android update project --path "." --target 2
#ATTENTION : IL FAUT CIBLER L'API 12
#si on cible la 10 alors il y a un probleme avec la bibliotheque SDL (par rapport au gamepad)

ndk-build
ant clean
ant release
cd bin
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $PATH_KEYSTORE -storepass $MDP SDLActivity-release-unsigned.apk nightly
zipalign 4 SDLActivity-release-unsigned.apk EasyRpgPlayerActivity.apk

cd ../../..