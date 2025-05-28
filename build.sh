#!/bin/bash

set -ex

git clone https://github.com/libsdl-org/SDL.git -b release-2.32.x
git clone https://github.com/libsdl-org/SDL_image -b release-2.8.x
curl -LO https://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.gz
tar xvfz libogg-1.3.5.tar.gz
curl -LO https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.gz
tar xvfz libvorbis-1.3.7.tar.gz

export NCPU=`sysctl -n hw.ncpu`
export CC="cc -arch x86_64 -arch arm64 -mmacosx-version-min=11.0"
export CXX="c++ -arch x86_64 -arch arm64 -mmacosx-version-min=11.0"
export OBJC="cc -arch x86_64 -arch arm64 -mmacosx-version-min=11.0"

cd SDL
./configure
make -j$NCPU
sudo make install

cd ../SDL_image
./configure
make -j$NCPU
sudo make install

cd ../libogg-1.3.5
mkdir flibitBuild
cd flibitBuild
cmake .. -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release
make -j$NCPU
sudo make install

cd ../../libvorbis-1.3.7
mkdir flibitBuild
cd flibitBuild
cmake .. -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release
make -j$NCPU
sudo make install

mkdir ../../output
cd ../../output
cp /usr/local/lib/libSDL2-2.0.0.dylib .
cp /usr/local/lib/libSDL2_image-2.0.0.dylib .
cp /usr/local/lib/libogg.0.dylib .
cp /usr/local/lib/libvorbis.0.4.9.dylib libvorbis.0.dylib
cp /usr/local/lib/libvorbisfile.3.3.8.dylib libvorbisfile.3.dylib
install_name_tool -id @rpath/libSDL2-2.0.0.dylib libSDL2-2.0.0.dylib
install_name_tool -id @rpath/libSDL2_image-2.0.0.dylib libSDL2_image-2.0.0.dylib
install_name_tool -id @rpath/libogg.0.dylib libogg.0.dylib
install_name_tool -id @rpath/libvorbis.0.dylib libvorbis.0.dylib
install_name_tool -id @rpath/libvorbisfile.3.dylib libvorbisfile.3.dylib
install_name_tool -change /usr/local/lib/libSDL2-2.0.0.dylib @rpath/libSDL2-2.0.0.dylib libSDL2_image-2.0.0.dylib
install_name_tool -change libogg.0.dylib @rpath/libogg.0.dylib libvorbis.0.dylib
install_name_tool -change libogg.0.dylib @rpath/libogg.0.dylib libvorbisfile.3.dylib
install_name_tool -change libvorbis.0.4.9.dylib @rpath/libvorbis.0.dylib libvorbisfile.3.dylib
strip -S *
file *
otool -L *
