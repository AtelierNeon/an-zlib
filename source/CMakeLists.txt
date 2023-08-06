cmake_minimum_required (VERSION 3.1)

## Dummy basic information for meta project
project (main)

message (STATUS "My project revision: ${MY_REVISION}")

## Project options
option (BUILD_WITH_SHARED_VCRT "Build library with shared vc runtime library." OFF)
option (BUILD_WITH_STATIC_VCRT "Build library without shared vc runtime library." OFF)
option (BUILD_WITH_WORKAROUND_ARM64RT "Build library with workaround arm64rt.lib library" OFF)
option (BUILD_WITH_WORKAROUND_OPT_GY "Build library with workaround /Gy compiler option" OFF)
option (BUILD_WITH_WORKAROUND_SPECTRE "Build library with workaround spectre mitigation library" OFF)

## Append custom CMake module path
list (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake-modules/")

## Import custom CMake modules
if (WIN32)
    include (MSVC-MyRuntimeConfig)
endif (WIN32)

## Process sub-components
add_subdirectory (zlib)
