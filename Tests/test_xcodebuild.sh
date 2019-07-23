#!/bin/bash

set -e
set -o pipefail

sudo xcode-select --switch /Applications/$1.app/Contents/Developer

xcodebuild -version
xcodebuild build -scheme Decree \
  -sdk iphonesimulator -destination "$IOS_DEVICE" | xcpretty
xcodebuild build -scheme Decree \
  -sdk appletvsimulator -destination "$TVOS_DEVICE" | xcpretty

if [ -n "$CODECOV_JOB" ]; then
  xcodebuild test -enableCodeCoverage YES -scheme Decree \
    -sdk macosx | xcpretty
  bash <(curl -s https://codecov.io/bash)
else
  xcodebuild test -scheme Decree \
    -sdk macosx | xcpretty
fi
