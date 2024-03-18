#!/usr/bin/env bash

alias odin=deps/Odin
export ODIN_ROOT=deps/Odin

odin build src/ -out=urban-tycoons -debug -reloc-mode:static
