#!/bin/sh

git submodule init

cd deps/Odin

./build_odin.sh

cd vendor/cgltf/src
make

cd ../../stb/src
make
