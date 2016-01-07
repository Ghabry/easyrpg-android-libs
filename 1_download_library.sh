#!/bin/bash

#Verify to have "hg" command
#Verify the autoconf command

# Supported os : "darwin" ou "linux"
os=$1
darwin="darwin"
linux="linux"

if [ $os = $darwin ] ; then
	echo "Darwin detected"
elif [ $os = $linux ] ; then
	echo "Linux detected"
else
	echo "OS not detected"
	exit
fi

export WORKSPACE=$PWD

#Compile toolchain
#Android SDK
#Linux
if [ $os = $linux ] ; then
	wget http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
	tar xf android-sdk_r24.4.1-linux.tgz
	mv android-sdk-linux android-sdk
#Mac
elif [ $os = $darwin ] ; then
	wget http://dl.google.com/android/android-sdk_r24.4.1-macosx.zip
	tar xf android-sdk_r24.4.1-macosx.zip
	mv android-sdk-macosx android-sdk
fi

PATH=$PATH:$WORKSPACE/android-ndk-r10e:$WORKSPACE/android-sdk/tools

# Install SDK12 and Platform-tools
num=$(android list sdk --all | grep "Android SDK Build-tools, revision 23.0.2" | head -n1 | awk '{gsub(/[^0-9]/,"", $1);print $1}')
echo "y" | android update sdk -u -a -t $num

num=$(android list sdk --all | grep "Android SDK Platform-tools" | head -n1 | awk '{gsub(/[^0-9]/,"", $1);print $1}')
echo "y" | android update sdk -u -a -t $num

num=$(android list sdk --all | grep "SDK Platform Android 3.1, API 12" | head -n1 | awk '{gsub(/[^0-9]/,"", $1);print $1}')
echo "y" | android update sdk -u -a -t $num


#Android NDK : depend on plateform
#Linux
if [ $os = $linux ] ; then
	wget http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
	chmod u+x android-ndk-r10e-linux-x86_64.bin
	./android-ndk-r10e-linux-x86_64.bin
	#rm android-ndk-r10e-linux-x86_64.bin
#Mac
elif [ $os = $darwin ] ; then
	wget http://dl.google.com/android/ndk/android-ndk-r10e-darwin-x86_64.bin
	chmod u+x android-ndk-r10e-darwin-x86_64.bin
	./android-ndk-r10e-darwin-x86_64.bin
	#rm android-ndk-r10e-darwin-x86_64.bin
fi

# Install boost header
wget http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.bz2
tar xf boost_1_60_0.tar.bz2

# Install libpng
wget http://prdownloads.sourceforge.net/libpng/libpng-1.6.20.tar.xz
tar xf libpng-1.6.20.tar.xz

# Install freetype
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.6.tar.bz2
tar xf freetype-2.6.tar.bz2

# Install pixman
tar xf pixman-0.32.8.tar.gz
wget http://cairographics.org/releases/pixman-0.32.8.tar.gz

# Install libogg
wget http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.xz
tar xf libogg-1.3.2.tar.xz

# Install libvorbis
wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.xz
tar xf libvorbis-1.3.5.tar.xz

# Install libmad
wget ftp://ftp.mars.org/pub/mpeg/libmad-0.15.1b.tar.gz
tar xf libmad-0.15.1b.tar.gz

# Install libmodplug
wget http://sourceforge.net/projects/modplug-xmms/files/libmodplug/0.8.8.5/libmodplug-0.8.8.5.tar.gz
tar xf libmodplug-0.8.8.5.tar.gz

# Install SDL2
hg clone http://hg.libsdl.org/SDL

# Install SDL2_mixer
hg clone http://hg.libsdl.org/SDL_mixer

# Install ICU
wget http://download.icu-project.org/files/icu4c/56.1/icu4c-56_1-src.tgz
tar xf icu4c-56_1-src.tgz