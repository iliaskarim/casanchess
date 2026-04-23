cmake_minimum_required(VERSION 3.20)
project(CasanchessSmoke LANGUAGES C CXX OBJC OBJCXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++23")

set(CMAKE_OSX_DEPLOYMENT_TARGET 16.3 CACHE STRING "Minimum iOS version" FORCE)

# Disable signing for local smoke builds.
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED NO)
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED NO)

add_subdirectory("../.." casanchess)
target_compile_options(casanchess PUBLIC "$<$<COMPILE_LANGUAGE:CXX>:-std=c++23>")

add_executable(CasanchessSmoke MACOSX_BUNDLE
    App/main.m
    App/AppDelegate.h
    App/AppDelegate.mm
)

target_include_directories(CasanchessSmoke PRIVATE
    "${CMAKE_SOURCE_DIR}/../../include"
)

target_link_libraries(CasanchessSmoke PRIVATE
    casanchess
    "-framework UIKit"
    "-framework Foundation"
)

set_target_properties(CasanchessSmoke PROPERTIES
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.casanchess.smoke"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
    XCODE_ATTRIBUTE_INFOPLIST_KEY_UIApplicationSceneManifest_Generation "NO"
)
