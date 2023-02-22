#!/bin/bash

#############################################
# README
# 
# This is the single script to use to build any part of this codebase
# 
# On Windows? Use git-bash to call bash scripts. This enables
# the codebase to use a single build system on every platform

#############################################
# Help Command / Documentation

print_help() {
  echo
  echo build_unified.sh Help
  echo "  $0 <command>"
  echo
  echo "Commands:"
  echo "  build <platform> <release_mode>"
  echo "  package <platform> <release_mode>"
  echo 
  echo "Platform Options:"
  echo "  win32, osx, android, ios"
  echo
  echo "Release Mode Options:"
  echo "  debug, release"
}

#############################################
# Options Parsing

OPTION_COMMAND=$1
if [ "${OPTION_COMMAND}" != "build" ] && [ "${OPTION_COMMAND}" != "package" ]; then
  OPTION_COMMAND="help"
fi

if [ "${OPTION_COMMAND}" == "help" ]; then
  print_help
  exit
fi

#############################################
# Utility Functions

pushdir () {
  command pushd "$@" > /dev/null
}

popdir () {
  command popd "$@" > /dev/null
}

#############################################
# Get the path to the project

SCRIPT_REL_DIR=$(dirname "${BASH_SOURCE[0]}")
pushd $SCRIPT_REL_DIR > /dev/null
cd ..
PROJECT_PATH=$(pwd)
popd > /dev/null

#############################################
# Project Configuration
# Change these as needed to suit your projects needs

OUTPUT_NAME="greenpastures"

# Win32 Configuration
CLANG_WIN32_ENTRY_POINT="${PROJECT_PATH}/src/win32_first.c"
CLANG_COMPILER_FLAGS_WIN32_DEBUG="-O0 -g -DDEBUG=1"
CLANG_COMPILER_FLAGS_WIN32_RELEASE="-O3"
CLANG_LINKER_FLAGS_WIN32_DEBUG=""
CLANG_LINKER_FLAGS_WIN32_RELEASE=""

# Osx Configuration
CLANG_OSX_ENTRY_POINT="${PROJECT_PATH}/src/osx_first.c"
CLANG_COMPILER_FLAGS_OSX_DEBUG="-O0 -g -DDEBUG=1"
CLANG_COMPILER_FLAGS_OSX_RELEASE="-O3"
CLANG_LINKER_FLAGS_OSX_DEBUG=""
CLANG_LINKER_FLAGS_OSX_RELEASE=""

# Android Configuration

# iOS Configuration

#############################################
# Build Commands

# If you set this to true, any compilation function you run will print out 
# the full compilation command it runs
PRINT_COMPILE_COMMAND="false"

# NOTE: before calling build_clang, these variables should be set
CLANG_COMPILER_OPTIONS=""
CLANG_LINKER_OPTIONS=""
CLANG_INPUT=""
CLANG_OUTPUT=""
build_clang () {
  echo "  Compiling To: ${CLANG_OUTPUT}"
  if [ "${PRINT_COMPILE_COMMAND}" == "true" ]; then
    echo clang $CLANG_COMPILER_OPTIONS $CLANG_LINKER_OPTIONS $CLANG_INPUT -o $CLANG_OUTPUT
  fi
  clang $CLANG_COMPILER_OPTIONS $CLANG_LINKER_OPTIONS $CLANG_INPUT -o $CLANG_OUTPUT
}

# BUILDING WINDOWS

build_win32 () {
  BUILD_WIN32_RELEASE_MODE=$1
  BUILD_WIN32_OUTPUT_DIR=$2
  if [ "${BUILD_WIN32_RELEASE_MODE}" == "debug" ]; then
    CLANG_COMPILER_OPTIONS=$CLANG_COMPILER_FLAGS_WIN32_DEBUG
    CLANG_LINKER_OPTIONS=$CLANG_LINKER_FLAGS_WIN32_DEBUG
  else
    CLANG_COMPILER_OPTIONS=$CLANG_COMPILER_FLAGS_WIN32_RELEASE
    CLANG_LINKER_OPTIONS=$CLANG_LINKER_FLAGS_WIN32_RELEASE
  fi
  CLANG_INPUT=$CLANG_WIN32_ENTRY_POINT
  CLANG_OUTPUT="${BUILD_WIN32_OUTPUT_DIR}/${OUTPUT_NAME}_win32.exe"
  build_clang
}

# BUILDING OSX

build_osx () {
  BUILD_OSX_RELEASE_MODE=$1
  BUILD_OSX_OUTPUT_DIR=$2
  if [ "${BUILD_OSX_RELEASE_MODE}" == "debug" ]; then
    CLANG_COMPILER_OPTIONS=$CLANG_COMPILER_FLAGS_OSX_DEBUG
    CLANG_LINKER_OPTIONS=$CLANG_LINKER_FLAGS_OSX_DEBUG
  else
    CLANG_COMPILER_OPTIONS=$CLANG_COMPILER_FLAGS_OSX_RELEASE
    CLANG_LINKER_OPTIONS=$CLANG_LINKER_FLAGS_OSX_RELEASE
  fi
  CLANG_INPUT=$CLANG_OSX_ENTRY_POINT
  CLANG_OUTPUT="${BUILD_OSX_OUTPUT_DIR}/${OUTPUT_NAME}_osx"
  build_clang
}

# BUILDING ANDROID

build_android () {
  echo "Building for android is not implemented yet"
}

# BUILDING IOS

build_ios () {
  echo "Building for ios is not implemented yet"
}

#############################################
# Script Entry Point

build_outer () {
  BUILD_PLATFORM=$1
  BUILD_RELEASE_MODE=$2
  echo "Building ${BUILD_PLATFORM} ${BUILD_RELEASE_MODE}"

  # Build Destination Folder
  BUILD_OUTPUT_DIR="${PROJECT_PATH}/run_tree/${BUILD_PLATFORM}/${BUILD_RELEASE_MODE}"
  if [ ! -d "$BUILD_OUTPUT_DIR" ]; then
    mkdir -p $BUILD_OUTPUT_DIR
  fi

  if [ "${BUILD_PLATFORM}" == "win32" ]; then
    build_win32 $BUILD_RELEASE_MODE $BUILD_OUTPUT_DIR
  elif [ "${BUILD_PLATFORM}" == "osx" ]; then
    build_osx $BUILD_RELEASE_MODE $BUILD_OUTPUT_DIR
  elif [ "${BUILD_PLATFORM}" == "android" ]; then
    build_ios $BUILD_RELEASE_MODE $BUILD_OUTPUT_DIR
  elif [ "${BUILD_PLATFORM}" == "ios" ]; then
    build_ios $BUILD_RELEASE_MODE $BUILD_OUTPUT_DIR
  else
    echo "Unknown build platform: ${BUILD_PLATFORM}"
    print_help
    exit
  fi
}

if [ "${OPTION_COMMAND}" == "build" ]; then
  build_outer $2 $3
fi

