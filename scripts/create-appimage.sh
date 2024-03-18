#!/bin/sh

linuxdeploy \
    --desktop-file=urban-tycoons.desktop \
    --appdir=AppDir \
    --executable=urban-tycoons \
    --icon-file=application-vnd.appimage.png

dependencies=$(ldd urban-tycoons | awk '{print $3}')

for dep in $dependencies; do
    cp "$dep" "AppDir/usr/lib"
done 

patchelf --set-rpath '$ORIGIN/../lib' "AppDir/usr/bin/urban-tycoons"

