#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SMOKE_DIR="${ROOT_DIR}/examples/xcode-smoke-macos"
BUILD_DIR="${SMOKE_DIR}/build"

ARCHS="${ARCHS:-arm64}"
CONFIG="${CONFIG:-Debug}"

echo "Generating macOS Xcode smoke project..."
cmake -S "${SMOKE_DIR}" -B "${BUILD_DIR}" -G Xcode \
  -DCMAKE_SYSTEM_NAME=Darwin \
  -DCMAKE_OSX_ARCHITECTURES="${ARCHS}"

# Remove Finder/resource-fork xattrs that can break codesign.
xattr -cr "${BUILD_DIR}" 2>/dev/null || true

echo "Building CasanchessSmokeMac (${CONFIG})..."
cmake --build "${BUILD_DIR}" --config "${CONFIG}" --target CasanchessSmokeMac

echo "Done."
echo "Project: ${BUILD_DIR}/CasanchessSmokeMac.xcodeproj"
