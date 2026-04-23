#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${ROOT_DIR}/build/apple"
OUT_DIR="${ROOT_DIR}/artifacts/apple"
INCLUDE_DIR="${ROOT_DIR}/include"

if ! command -v cmake >/dev/null 2>&1; then
  echo "error: cmake not found in PATH" >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "error: xcodebuild not found in PATH" >&2
  exit 1
fi

configure_and_build() {
  local platform="$1"
  local sysroot="$2"
  local archs="$3"

  local build_dir="${BUILD_ROOT}/${platform}"
  local lib_out="${build_dir}/artifacts"

  rm -rf "${build_dir}"

  cmake -S "${ROOT_DIR}" -B "${build_dir}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="${sysroot}" \
    -DCMAKE_OSX_ARCHITECTURES="${archs}" \
    -DBUILD_TESTS=OFF \
    -DBUILD_TESTS_EXTRA=OFF \
    -DBUILD_EXECUTABLES_EXTRA=OFF \
    -DENABLE_LTO=OFF \
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="${lib_out}" \
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE="${lib_out}"

  cmake --build "${build_dir}" --target casanchess --parallel
}

configure_and_build_macos() {
  local build_dir="${BUILD_ROOT}/macos"
  local lib_out="${build_dir}/artifacts"

  rm -rf "${build_dir}"

  cmake -S "${ROOT_DIR}" -B "${build_dir}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DBUILD_TESTS=OFF \
    -DBUILD_TESTS_EXTRA=OFF \
    -DBUILD_EXECUTABLES_EXTRA=OFF \
    -DENABLE_LTO=OFF \
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="${lib_out}" \
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE="${lib_out}"

  cmake --build "${build_dir}" --target casanchess --parallel
}

configure_and_build_catalyst_arch() {
  local arch="$1"
  local build_dir="${BUILD_ROOT}/maccatalyst-${arch}"
  local lib_out="${build_dir}/artifacts"
  local target="${arch}-apple-ios14.0-macabi"

  rm -rf "${build_dir}"

  cmake -S "${ROOT_DIR}" -B "${build_dir}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=Darwin \
    -DCMAKE_OSX_SYSROOT="macosx" \
    -DCMAKE_OSX_ARCHITECTURES="${arch}" \
    -DCMAKE_CXX_FLAGS="-target ${target}" \
    -DBUILD_TESTS=OFF \
    -DBUILD_TESTS_EXTRA=OFF \
    -DBUILD_EXECUTABLES_EXTRA=OFF \
    -DENABLE_LTO=OFF \
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="${lib_out}" \
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE="${lib_out}"

  cmake --build "${build_dir}" --target casanchess --parallel
}

mkdir -p "${OUT_DIR}"

configure_and_build_macos
configure_and_build "iphoneos" "iphoneos" "arm64"
configure_and_build "iphonesimulator" "iphonesimulator" "arm64;x86_64"
configure_and_build_catalyst_arch "arm64"
configure_and_build_catalyst_arch "x86_64"

MAC_LIB="${BUILD_ROOT}/macos/artifacts/libcasanchess.a"
IOS_LIB="${BUILD_ROOT}/iphoneos/artifacts/libcasanchess.a"
SIM_LIB="${BUILD_ROOT}/iphonesimulator/artifacts/libcasanchess.a"
MACCATALYST_ARM64_LIB="${BUILD_ROOT}/maccatalyst-arm64/artifacts/libcasanchess.a"
MACCATALYST_X64_LIB="${BUILD_ROOT}/maccatalyst-x86_64/artifacts/libcasanchess.a"

cp "${MAC_LIB}" "${OUT_DIR}/libcasanchess-macos.a"
cp "${IOS_LIB}" "${OUT_DIR}/libcasanchess-iphoneos.a"
cp "${SIM_LIB}" "${OUT_DIR}/libcasanchess-iphonesimulator.a"
lipo -create \
  "${MACCATALYST_ARM64_LIB}" \
  "${MACCATALYST_X64_LIB}" \
  -output "${OUT_DIR}/libcasanchess-maccatalyst.a"

rm -rf "${OUT_DIR}/casanchess.xcframework"

xcodebuild -create-xcframework \
  -library "${OUT_DIR}/libcasanchess-macos.a" -headers "${INCLUDE_DIR}" \
  -library "${OUT_DIR}/libcasanchess-iphoneos.a" -headers "${INCLUDE_DIR}" \
  -library "${OUT_DIR}/libcasanchess-iphonesimulator.a" -headers "${INCLUDE_DIR}" \
  -library "${OUT_DIR}/libcasanchess-maccatalyst.a" -headers "${INCLUDE_DIR}" \
  -output "${OUT_DIR}/casanchess.xcframework"

echo "Built Apple libraries:"
echo "  ${OUT_DIR}/libcasanchess-macos.a"
echo "  ${OUT_DIR}/libcasanchess-iphoneos.a"
echo "  ${OUT_DIR}/libcasanchess-iphonesimulator.a"
echo "  ${OUT_DIR}/libcasanchess-maccatalyst.a"
echo "  ${OUT_DIR}/casanchess.xcframework"
