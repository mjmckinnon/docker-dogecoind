#!/bin/bash
set -e

VERSION="$1"
COMPILEFLAGS="$2"

echo "** configuring and compiling **"
./autogen.sh
./configure CXXFLAG="-O2" LDFLAGS=-static-libstdc++ $COMPILEFLAGS
make

echo "** installing and stripping the binaries **"
mkdir -p /dist-files
make install DESTDIR=/dist-files
strip /dist-files/usr/local/bin/*

echo "** removing extra lib files **"
find /dist-files -name "lib*.la" -delete
find /dist-files -name "lib*.a" -delete

echo "** build cleanup **"
cd ..
rm -rf "$GITREPO"
