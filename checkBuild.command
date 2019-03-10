#!/bin/bash

set -e

base_dir=$(dirname "$0")
cd "$base_dir"

echo ""

set -o pipefail && xcodebuild -workspace "Example/APLineGraph.xcworkspace" -scheme "APLineGraph-Example" -configuration "Release" -sdk iphonesimulator12.1 | xcpretty

echo ""

xcodebuild -project "CarthageSupport/APLineGraph.xcodeproj" -alltargets -sdk iphonesimulator12.1 | xcpretty

echo ""
echo "SUCCESS!"
echo ""
