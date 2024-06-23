#!/usr/bin/env bash

alias odin=deps/Odin
export ODIN_ROOT=deps/Odin

./deps/Odin/odin build src/ -out=urban-tycoons -debug -sanitize:address
