#!/bin/sh

deps/Odin/odin build src/ -out=urban-tycoons -o:speed -extra-linker-flags:"-pthread -ldl"
