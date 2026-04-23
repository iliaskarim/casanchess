cmake_minimum_required(VERSION 3.20)
project(CasanchessSmoke LANGUAGES C CXX OBJC OBJCXX Swift)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++23")

set(CMAKE_OSX_DEPLOYMENT_TARGET 16.3 CACHE STRING "Minimum iOS version" FORCE)

add_subdirectory("../.." casanchess)
target_compile_options(casanchess PUBLIC "$<$<COMPILE_LANGUAGE:CXX>:-std=c++23>")

add_executable(CasanchessSmoke MACOSX_BUNDLE
    App/CasanchessSmokeApp.swift
    App/EngineBridge.h
    App/EngineBridge.mm
    App/BridgingHeader.h
)

set(SMOKE_BUNDLE_IDENTIFIER "com.casanchess.smoke")
set(SMOKE_BUNDLE_NAME "CasanchessSmoke")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/App/Info.plist.in"
    "${CMAKE_CURRENT_BINARY_DIR}/Info.plist"
    @ONLY
)

target_include_directories(CasanchessSmoke PRIVATE
    "${CMAKE_SOURCE_DIR}/../../include"
)

target_link_libraries(CasanchessSmoke PRIVATE
    casanchess
    "-framework SwiftUI"
    "-framework Foundation"
)

set_target_properties(CasanchessSmoke PROPERTIES
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/Info.plist"
    MACOSX_BUNDLE_GUI_IDENTIFIER "${SMOKE_BUNDLE_IDENTIFIER}"
    XCODE_ATTRIBUTE_INFOPLIST_FILE "${CMAKE_CURRENT_BINARY_DIR}/Info.plist"
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "${SMOKE_BUNDLE_IDENTIFIER}"
    XCODE_ATTRIBUTE_INFOPLIST_KEY_CFBundleIdentifier "${SMOKE_BUNDLE_IDENTIFIER}"
    XCODE_ATTRIBUTE_INFOPLIST_KEY_CFBundleName "${SMOKE_BUNDLE_NAME}"
    XCODE_ATTRIBUTE_INFOPLIST_KEY_CFBundleDisplayName "${SMOKE_BUNDLE_NAME}"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
    XCODE_ATTRIBUTE_SWIFT_VERSION "5.0"
    XCODE_ATTRIBUTE_SWIFT_OBJC_BRIDGING_HEADER "App/BridgingHeader.h"
)

# Clear stale xattrs on each build to avoid codesign failures
# ("resource fork, Finder information, or similar detritus not allowed").
add_custom_command(TARGET CasanchessSmoke PRE_BUILD
    COMMAND /usr/bin/xattr -cr "${CMAKE_CURRENT_BINARY_DIR}" || true
    VERBATIM
)
