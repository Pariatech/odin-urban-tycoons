#!/bin/sh

docker build -t build-urban-tycoons-windows -f Dockerfile.windows .

docker run --rm -v $(pwd):/game -w /game build-urban-tycoons-windows
