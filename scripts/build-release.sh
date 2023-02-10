#!/bin/sh

set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
project_dir="$(dirname "$script_dir")"

cd "$project_dir"

executable_product="uapm"
# Build universal binary
swift build -c release --arch arm64 --arch x86_64 --product "$executable_product"
# Ask swift build for the output directory
built_executable_dir=$(swift build -c release --arch arm64 --arch x86_64 --product "$executable_product" --show-bin-path)
built_executable="$built_executable_dir/$executable_product"
echo "$built_executable"
