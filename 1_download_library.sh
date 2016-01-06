#Verify to have "hg" command
#Verify the autoconf command

#Compile toolchain

#Android SDK
#Linux
wget http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
#Mac
wget http://dl.google.com/android/android-sdk_r24.4.1-macosx.zip

# Install SDK12 and Platform-tools
num=$(android list sdk --all | grep "Android SDK Build-tools, revision 23.0.2" | head -n1 | awk '{gsub(/[^0-9]/,"", $1);print $1}')
echo "y" | android update sdk -u -a -t $num

num=$(android list sdk --all | grep "Android SDK Platform-tools" | head -n1 | awk '{gsub(/[^0-9]/,"", $1);print $1}')
echo "y" | android update sdk -u -a -t $num

num=$(android list sdk --all | grep "SDK Platform Android 3.1, API 12" | head -n1 | awk '{gsub(/[^0-9]/,"", $1);print $1}')
echo "y" | android update sdk -u -a -t $num


#Android NDK : depend on plateform
#Linux
wget http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
chmod u+x android-ndk-r10e-linux-x86_64.bin
./android-ndk-r10e-linux-x86_64.bin
rm android-ndk-r10e-linux-x86_64.bin
#Mac
wget http://dl.google.com/android/ndk/android-ndk-r10e-darwin-x86_64.bin
chmod u+x android-ndk-r10e-darwin-x86_64.bin
./android-ndk-r10e-darwin-x86_64.bin
rm android-ndk-r10e-darwin-x86_64.bin


wget http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.bz2
wget http://prdownloads.sourceforge.net/libpng/libpng-1.6.20.tar.xz
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.6.tar.bz2
wget http://cairographics.org/releases/pixman-0.32.8.tar.gz
wget http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.xz
wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.xz
wget ftp://ftp.mars.org/pub/mpeg/libmad-0.15.1b.tar.gz
wget http://sourceforge.net/projects/modplug-xmms/files/libmodplug/0.8.8.5/libmodplug-0.8.8.5.tar.gz


hg clone http://hg.libsdl.org/SDL
hg clone http://hg.libsdl.org/SDL_mixer
wget http://download.icu-project.org/files/icu4c/56.1/icu4c-56_1-src.tgz