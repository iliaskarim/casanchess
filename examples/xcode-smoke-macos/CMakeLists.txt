cmake_minimum_required(VERSION 3.20)
project(CasanchessSmokeMac LANGUAGES C CXX OBJC OBJCXX Swift)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++23")
set(CMAKE_OSX_DEPLOYMENT_TARGET 14.0 CACHE STRING "Minimum macOS version" FORCE)
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED NO)
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED NO)

add_subdirectory("../.." casanchess)
target_compile_options(casanchess PUBLIC "$<$<COMPILE_LANGUAGE:CXX>:-std=c++23>")

add_executable(CasanchessSmokeMac MACOSX_BUNDLE
    App/CasanchessSmokeMacApp.swift
    App/EngineBridge.h
    App/EngineBridge.mm
    App/BridgingHeader.h
)

target_include_directories(CasanchessSmokeMac PRIVATE
    "${CMAKE_SOURCE_DIR}/../../include"
)

target_link_libraries(CasanchessSmokeMac PRIVATE
    casanchess
    "-framework SwiftUI"
    "-framework Foundation"
)

set_target_properties(CasanchessSmokeMac PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.casanchess.smoke.macos"
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.casanchess.smoke.macos"
    XCODE_ATTRIBUTE_INFOPLIST_KEY_CFBundleIdentifier "com.casanchess.smoke.macos"
    XCODE_ATTRIBUTE_SWIFT_VERSION "5.0"
    XCODE_ATTRIBUTE_SWIFT_OBJC_BRIDGING_HEADER "App/BridgingHeader.h"
)

# Clear stale xattrs on each build to avoid codesign failures
# ("resource fork, Finder information, or similar detritus not allowed").
add_custom_command(TARGET CasanchessSmokeMac PRE_BUILD
    COMMAND /usr/bin/xattr -cr "${CMAKE_CURRENT_BINARY_DIR}" || true
    VERBATIM
)
