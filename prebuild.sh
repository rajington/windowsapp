#!/usr/bin/env bash

xcodebuild
VERSION=$(defaults read $(pwd)/Windows/Windows-Info CFBundleVersion)
FILENAME="Builds/Windows-$VERSION.app.tar.gz"
LATEST="Windows.app.tar.gz"
tar -zcf $FILENAME build/Release/Windows.app
rm $LATEST
ln -s $FILENAME $LATEST
