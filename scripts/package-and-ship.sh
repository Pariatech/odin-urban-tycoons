#!/bin/sh

./scripts/package-linux-build.sh && \
    ./scripts/package-windows-build.sh && \
    ./scripts/push-linux-package-to-itch.sh && \
    ./scripts/push-windows-package-to-itch.sh 
