export WORKSPACE=$PWD

# Patch cpufeatures, hangs in Android 4.0.3
patch -Np0 < cpufeatures.patch

# Setup PATH
PATH=$PATH:$WORKSPACE/android-ndk-r10e:$WORKSPACE/android-sdk-linux/tools

####################################################
# Install standalone toolchain x86
export NDK_ROOT=$WORKSPACE/android-ndk-r10e
export PLATFORM_PREFIX=$WORKSPACE/x86-toolchain
$NDK_ROOT/build/tools/make-standalone-toolchain.sh --platform=android-9 --ndk-dir=$NDK_ROOT --toolchain=x86-4.9 --install-dir=$PLATFORM_PREFIX --stl=gnustl

export OLD_PATH=$PATH
export PATH=$PLATFORM_PREFIX/bin:$PATH

export CPPFLAGS="-I$PLATFORM_PREFIX/include -I$NDK_ROOT/sources/android/support/include"
export LDFLAGS="-L$PLATFORM_PREFIX/lib"
export PKG_CONFIG_PATH=$PLATFORM_PREFIX/lib/pkgconfig
export TARGET_HOST="i686-linux-android"

# Install boost header
cp -r boost_1_60_0/boost/ $PLATFORM_PREFIX/include/boost/

# Install libpng
cd libpng-1.6.20
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install freetype
cd freetype-2.6
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static --with-harfbuzz=no
make -j2
# ERROR ??
make install
cd ..

# Install pixman
cd pixman-0.32.8
sed -i.bak 's/SUBDIRS = pixman demos test/SUBDIRS = pixman/' Makefile.am
autoreconf -fi
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
#ERROR
make install
cd ..


