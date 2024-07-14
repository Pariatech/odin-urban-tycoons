#!/usr/bin/env bash

alias odin=deps/Odin
export ODIN_ROOT=deps/Odin

OS=$(uname)

if [[ "$OS" == "Darwin" ]]; then
    ./deps/Odin/odin build src/ -out=urban-tycoons -debug -extra-linker-flags:"-rpath @executable_path/libs"
else 
    ./deps/Odin/odin build src/ -out=urban-tycoons -debug -sanitize:address
fi
