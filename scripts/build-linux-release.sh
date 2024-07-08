#!/bin/sh

deps/Odin/odin build src/ -out=urban-tycoons -o:aggressive -extra-linker-flags:"-pthread -ldl"
