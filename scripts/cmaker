#!/bin/bash
CMAKE_VERSION=3.19.1
wget -q https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz
tar -xzf cmake-$CMAKE_VERSION.tar.gz
rm cmake-$CMAKE_VERSION.tar.gz
cd cmake-$CMAKE_VERSION
./bootstrap
make
make install
cd ..
rm -Rf cmake-$CMAKE_VERSION
