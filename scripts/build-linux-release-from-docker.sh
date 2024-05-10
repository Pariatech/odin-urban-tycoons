#!/bin/sh

docker build -t build-urban-tycoons-linux -f Dockerfile.linux .

docker run --rm -v $(pwd):/game -w /game build-urban-tycoons-linux
