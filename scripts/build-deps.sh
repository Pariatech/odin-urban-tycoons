#!/bin/sh

git submodule init

pwd=$(pwd)

cd "$pwd/deps/glfw"
mkdir build
cd build
cmake ..
make -j4
cp src/libglfw3.a "$pwd/deps/Odin/vendor/glfw/lib/"

cd "$pwd/deps/Odin"

./build_odin.sh

cd vendor/cgltf/src
make

cd ../../stb/src
make

