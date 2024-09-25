#!/usr/bin/env bash

ODIN_ROOT=$(pwd)/deps/Odin

OS=$(uname)

if [[ "$OS" == "Darwin" ]]; then
    $ODIN_ROOT/odin build src/ -out=urban-tycoons -debug -extra-linker-flags:"-rpath @executable_path/libs"
else 
    $ODIN_ROOT/odin build src/ -out=urban-tycoons -debug -sanitize:address
fi
