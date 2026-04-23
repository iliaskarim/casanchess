#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SMOKE_DIR="${ROOT_DIR}/examples/xcode-smoke-ios"
BUILD_DIR="${SMOKE_DIR}/build"

SDK="${SDK:-iphoneos}"
ARCHS="${ARCHS:-arm64}"
CONFIG="${CONFIG:-Debug}"

echo "Generating Xcode smoke project..."
cmake -S "${SMOKE_DIR}" -B "${BUILD_DIR}" -G Xcode \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT="${SDK}" \
  -DCMAKE_OSX_ARCHITECTURES="${ARCHS}"

# Remove Finder/resource-fork xattrs that can break codesign.
xattr -cr "${BUILD_DIR}" 2>/dev/null || true

echo "Building CasanchessSmoke (${CONFIG})..."
cmake --build "${BUILD_DIR}" --config "${CONFIG}" --target CasanchessSmoke

echo "Done."
echo "Project: ${BUILD_DIR}/CasanchessSmoke.xcodeproj"
