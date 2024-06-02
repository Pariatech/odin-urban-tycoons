#!/bin/sh

git submodule init

pwd=$(pwd)
# export CC=clang-13
# cp $(which clang-13) /usr/bin/clang
# alias clang=clang-13

echo "----- GLFW ----"
cd "$pwd/deps/glfw"
rm -rf build
mkdir -p build
cd build
cmake ..
make -j4
cp src/libglfw3.a "$pwd/deps/Odin/vendor/glfw/lib/"

cd "$pwd/deps/Odin"

echo "----- ODIN ----"
./build_odin.sh

echo "----- CGLTF ----"
cd "$pwd/deps/Odin/vendor/cgltf/src"
make

echo "----- STB ----"
cd "$pwd/deps/Odin/vendor/stb/src"
make

