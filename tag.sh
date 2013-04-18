#!/usr/bin/env bash

VERSION=$(defaults read $(pwd)/Windows/Windows-Info CFBundleVersion)
git tag $VERSION
git push --tags
