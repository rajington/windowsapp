#!/usr/bin/env bash

xcodebuild
VERSION=$(defaults read $(pwd)/Windows/Windows-Info CFBundleVersion)
FILENAME="Builds/Windows-$VERSION.app.tar.gz"
LATEST="Builds/Windows.app-latest.tar.gz"
rm -rf $FILENAME
tar -zcf $FILENAME -C build/Release Windows.app
rm -f $LATEST
cp $FILENAME $LATEST
