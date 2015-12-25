#!/bin/bash
export WORKSPACE=$PWD

# Compile toolchain
wget http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
tar xf android-sdk_r24.4.1-linux.tgz
rm android-sdk_r24.4.1-linux.tgz

wget http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
7z x android-ndk-r10e-linux-x86_64.bin
rm android-ndk-r10e-linux-x86_64.bin

# Patch cpufeatures, hangs in Android 4.0.3
patch -Np0 < cpufeatures.patch

# Setup PATH
PATH=$PATH:$WORKSPACE/android-ndk-r10e:$WORKSPACE/android-sdk-linux/tools

# Install SDK12 and Platform-tools
num=$(android list sdk --all | grep "Android SDK Build-tools, revision 23.0.2" | head -n1 | awk '{gsub(/[^0-9]/,"", $1);print $1}')
echo "y" | android update sdk -u -a -t $num

num=$(android list sdk --all | grep "Android SDK Platform-tools" | head -n1 | awk '{gsub(/[^0-9]/,"", $1);print $1}')
echo "y" | android update sdk -u -a -t $num

num=$(android list sdk --all | grep "SDK Platform Android 3.1, API 12" | head -n1 | awk '{gsub(/[^0-9]/,"", $1);print $1}')
echo "y" | android update sdk -u -a -t $num

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
wget http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.bz2
tar xf boost_1_60_0.tar.bz2
cp -r boost_1_60_0/boost/ $PLATFORM_PREFIX/include/boost/

# Install libpng
wget http://prdownloads.sourceforge.net/libpng/libpng-1.6.20.tar.xz
tar xf libpng-1.6.20.tar.xz
cd libpng-1.6.20
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install freetype
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.6.tar.bz2
tar xf freetype-2.6.tar.bz2
cd freetype-2.6
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static --with-harfbuzz=no
make -j2
make install
cd ..

# Install pixman
wget http://cairographics.org/releases/pixman-0.32.8.tar.gz
tar xf pixman-0.32.8.tar.gz
cd pixman-0.32.8
sed -i.bak 's/SUBDIRS = pixman demos test/SUBDIRS = pixman/' Makefile.am
autoreconf -fi
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libogg
wget http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.xz
tar xf libogg-1.3.2.tar.xz
cd libogg-1.3.2
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libvorbis
wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.xz
tar xf libvorbis-1.3.5.tar.xz
cd libvorbis-1.3.5
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libmad
wget ftp://ftp.mars.org/pub/mpeg/libmad-0.15.1b.tar.gz
tar xf libmad-0.15.1b.tar.gz
cd libmad-0.15.1b
patch -Np1 < ../libmad-pkg-config.diff
autoreconf -fi
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libmodplug
wget http://sourceforge.net/projects/modplug-xmms/files/libmodplug/0.8.8.5/libmodplug-0.8.8.5.tar.gz
tar xf libmodplug-0.8.8.5.tar.gz
cd libmodplug-0.8.8.5
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install SDL2
hg clone http://hg.libsdl.org/SDL
cd SDL
mv include/SDL_config_android.h include/SDL_config.h
mkdir jni
echo "APP_STL := gnustl_static" > "jni/Application.mk"
echo "APP_ABI := armeabi armeabi-v7a x86 mips" >> "jni/Application.mk"
ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk APP_PLATFORM=android-9
cp libs/x86/* $PLATFORM_PREFIX/lib/
cp include/* $PLATFORM_PREFIX/include/
cd ..

# Install SDL2_mixer
hg clone http://hg.libsdl.org/SDL_mixer
cd SDL_mixer
patch -Np1 -d timidity < ../timidity-android.patch
sed -i.bak 's/LT_LDFLAGS.*$/LT_LDFLAGS = -no-undefined -rpath $(libdir) -release $(LT_RELEASE) -avoid-version/' Makefile.in
sed -i.bak 's/^all:.*$/all: $(srcdir)\/configure Makefile $(objects) $(objects)\/$(TARGET)/' Makefile.in
sh autogen.sh
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --enable-music-mp3-mad-gpl --disable-sdltest --disable-music-mod
make -j2
touch build/.libs/libSDL2_mixer.lai
make install
cd ..

# Install ICU
wget http://download.icu-project.org/files/icu4c/56.1/icu4c-56_1-src.tgz
tar xf icu4c-56_1-src.tgz

unset CPPFLAGS
unset LDFLAGS

cp -r icu icu-native
cp icudt56l.dat icu/source/data/in/
cp icudt56l.dat icu-native/source/data/in/
cd icu-native/source
sed -i.bak 's/SMALL_BUFFER_MAX_SIZE 512/SMALL_BUFFER_MAX_SIZE 2048/' tools/toolutil/pkg_genc.h
chmod u+x configure
./configure --enable-static --enable-shared=no --enable-tests=no --enable-samples=no --enable-dyload=no --enable-tools --enable-extras=no --enable-icuio=no --with-data-packaging=static
make -j2
export ICU_CROSS_BUILD=$PWD

# Cross compile ICU
cd ../../icu/source

export CPPFLAGS="-I$PLATFORM_PREFIX/include -I$NDK_ROOT/sources/cxx-stl/stlport/stlport -O3 -fno-short-wchar -DU_USING_ICU_NAMESPACE=0 -DU_GNUC_UTF16_STRING=0 -fno-short-enums -nostdlib"
export LDFLAGS="-lc -Wl,-rpath-link=$PLATFORM_PREFIX/lib -L$PLATFORM_PREFIX/lib/"

chmod u+x configure
./configure --with-cross-build=$ICU_CROSS_BUILD --enable-strict=no  --enable-static --enable-shared=no --enable-tests=no --enable-samples=no --enable-dyload=no --enable-tools=no --enable-extras=no --enable-icuio=no --host=$TARGET_HOST --with-data-packaging=static --prefix=$PLATFORM_PREFIX

make -j2
make install

unset CPPFLAGS
unset LDFLAGS

################################################################
# Install standalone toolchain ARM
cd $WORKSPACE

export PATH=$OLD_PATH
export PLATFORM_PREFIX=$WORKSPACE/armeabi-toolchain
$NDK_ROOT/build/tools/make-standalone-toolchain.sh --platform=android-9 --ndk-dir=$NDK_ROOT --toolchain=arm-linux-androideabi-4.9 --install-dir=$PLATFORM_PREFIX  --stl=gnustl
export PATH=$PLATFORM_PREFIX/bin:$PATH

export CPPFLAGS="-I$PLATFORM_PREFIX/include -I$NDK_ROOT/sources/android/support/include -I$NDK_ROOT/sources/android/cpufeatures"
export LDFLAGS="-L$PLATFORM_PREFIX/lib"
export PKG_CONFIG_PATH=$PLATFORM_PREFIX/lib/pkgconfig
export TARGET_HOST="arm-linux-androideabi"

# Install boost header
cp -r boost_1_60_0/boost/ $PLATFORM_PREFIX/include/boost/

# Install libpng
cd libpng-1.6.20
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install freetype
cd freetype-2.6
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static --with-harfbuzz=no
make -j2
make install
cd ..

# Install pixman
cd pixman-0.32.8
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libogg
cd libogg-1.3.2
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libvorbis
cd libvorbis-1.3.5
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libmad
cd libmad-0.15.1b
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libmodplug
cd libmodplug-0.8.8.5
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install SDL2
cd SDL
# Was already compiled because of Android.mk voodoo
cp libs/armeabi/* $PLATFORM_PREFIX/lib/
cp include/* $PLATFORM_PREFIX/include/
cd ..

# Install SDL2_mixer
cd SDL_mixer
make clean
sed -i.bak 's/LT_LDFLAGS.*$/LT_LDFLAGS = -no-undefined -rpath $(libdir) -release $(LT_RELEASE) -avoid-version/' Makefile.in
sh autogen.sh
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --enable-music-mp3-mad-gpl --disable-sdltest --disable-music-mod
make -j2
touch build/.libs/libSDL2_mixer.lai
make install
cd ..

# Cross compile ICU
cd icu/source

export CPPFLAGS="-I$PLATFORM_PREFIX/include -I$NDK_ROOT/sources/cxx-stl/stlport/stlport -O3 -fno-short-wchar -DU_USING_ICU_NAMESPACE=0 -DU_GNUC_UTF16_STRING=0 -fno-short-enums -nostdlib"
export LDFLAGS="-lc -Wl,-rpath-link=$PLATFORM_PREFIX/lib -L$PLATFORM_PREFIX/lib/"

chmod u+x configure
make clean
./configure --with-cross-build=$ICU_CROSS_BUILD --enable-strict=no  --enable-static --enable-shared=no --enable-tests=no --enable-samples=no --enable-dyload=no --enable-tools=no --enable-extras=no --enable-icuio=no --host=$TARGET_HOST --with-data-packaging=static --prefix=$PLATFORM_PREFIX

make -j2
make install

################################################################
# Install standalone toolchain ARM
cd $WORKSPACE

# Setting up new toolchain not required, only difference is CPPFLAGS

export CPPFLAGS="-I$PLATFORM_PREFIX/include -I$NDK_ROOT/sources/android/support/include -I$NDK_ROOT/sources/android/cpufeatures -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3"
export LDFLAGS="-L$PLATFORM_PREFIX/lib"
export PKG_CONFIG_PATH=$PLATFORM_PREFIX/lib/pkgconfig
export TARGET_HOST="arm-linux-androideabi"

# Install boost header
cp -r boost_1_60_0/boost/ $PLATFORM_PREFIX/include/boost/

# Install libpng
cd libpng-1.6.20
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install freetype
cd freetype-2.6
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static --with-harfbuzz=no
make -j2
make install
cd ..

# Install pixman
cd pixman-0.32.8
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libogg
cd libogg-1.3.2
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libvorbis
cd libvorbis-1.3.5
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libmad
cd libmad-0.15.1b
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libmodplug
cd libmodplug-0.8.8.5
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install SDL2
cd SDL
# Was already compiled because of Android.mk voodoo
cp libs/armeabi-v7a/* $PLATFORM_PREFIX/lib/
cp include/* $PLATFORM_PREFIX/include/
cd ..

# Install SDL2_mixer
cd SDL_mixer
make clean
sed -i.bak 's/LT_LDFLAGS.*$/LT_LDFLAGS = -no-undefined -rpath $(libdir) -release $(LT_RELEASE) -avoid-version/' Makefile.in
sh autogen.sh
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --enable-music-mp3-mad-gpl --disable-sdltest --disable-music-mod
make -j2
touch build/.libs/libSDL2_mixer.lai
make install
cd ..

# Cross compile ICU
cd icu/source

export CPPFLAGS="-I$PLATFORM_PREFIX/include -I$NDK_ROOT/sources/cxx-stl/stlport/stlport -O3 -fno-short-wchar -DU_USING_ICU_NAMESPACE=0 -DU_GNUC_UTF16_STRING=0 -fno-short-enums -nostdlib -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3"
export LDFLAGS="-lc -Wl,-rpath-link=$PLATFORM_PREFIX/lib -L$PLATFORM_PREFIX/lib/"

chmod u+x configure
make clean
./configure --with-cross-build=$ICU_CROSS_BUILD --enable-strict=no  --enable-static --enable-shared=no --enable-tests=no --enable-samples=no --enable-dyload=no --enable-tools=no --enable-extras=no --enable-icuio=no --host=$TARGET_HOST --with-data-packaging=static --prefix=$PLATFORM_PREFIX

make -j2
make install

################################################################
# Install standalone toolchain MIPS
cd $WORKSPACE

export PATH=$OLD_PATH
export PLATFORM_PREFIX=$WORKSPACE/mips-toolchain
$NDK_ROOT/build/tools/make-standalone-toolchain.sh --platform=android-9 --ndk-dir=$NDK_ROOT --toolchain=mipsel-linux-android-4.9 --install-dir=$PLATFORM_PREFIX  --stl=gnustl
export PATH=$PLATFORM_PREFIX/bin:$PATH

export CPPFLAGS="-I$PLATFORM_PREFIX/include -I$NDK_ROOT/sources/android/support/include -I$NDK_ROOT/sources/android/cpufeatures"
export LDFLAGS="-L$PLATFORM_PREFIX/lib"
export PKG_CONFIG_PATH=$PLATFORM_PREFIX/lib/pkgconfig
export TARGET_HOST="mipsel-linux-android"

# Install boost header
cp -r boost_1_60_0/boost/ $PLATFORM_PREFIX/include/boost/

# Install libpng
cd libpng-1.6.20
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install freetype
cd freetype-2.6
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static --with-harfbuzz=no
make -j2
make install
cd ..

# Install pixman
cd pixman-0.32.8
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libogg
cd libogg-1.3.2
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libvorbis
cd libvorbis-1.3.5
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libmad
cd libmad-0.15.1b
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install libmodplug
cd libmodplug-0.8.8.5
make clean
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --disable-shared --enable-static
make -j2
make install
cd ..

# Install SDL2
cd SDL
# Was already compiled because of Android.mk voodoo
cp libs/mips/* $PLATFORM_PREFIX/lib/
cp include/* $PLATFORM_PREFIX/include/
cd ..

# Install SDL2_mixer
cd SDL_mixer
make clean
sed -i.bak 's/LT_LDFLAGS.*$/LT_LDFLAGS = -no-undefined -rpath $(libdir) -release $(LT_RELEASE) -avoid-version/' Makefile.in
sh autogen.sh
./configure --host=$TARGET_HOST --prefix=$PLATFORM_PREFIX --enable-music-mp3-mad-gpl --disable-sdltest --disable-music-mod
make -j2
touch build/.libs/libSDL2_mixer.lai
make install
cd ..

# Cross compile ICU
cd icu/source

export CPPFLAGS="-I$PLATFORM_PREFIX/include -I$NDK_ROOT/sources/cxx-stl/stlport/stlport -O3 -fno-short-wchar -DU_USING_ICU_NAMESPACE=0 -DU_GNUC_UTF16_STRING=0 -fno-short-enums -nostdlib"
export LDFLAGS="-lc -Wl,-rpath-link=$PLATFORM_PREFIX/lib -L$PLATFORM_PREFIX/lib/"

chmod u+x configure
make clean
./configure --with-cross-build=$ICU_CROSS_BUILD --enable-strict=no  --enable-static --enable-shared=no --enable-tests=no --enable-samples=no --enable-dyload=no --enable-tools=no --enable-extras=no --enable-icuio=no --host=$TARGET_HOST --with-data-packaging=static --prefix=$PLATFORM_PREFIX

make -j2
make install
