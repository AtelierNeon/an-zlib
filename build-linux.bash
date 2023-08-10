#!/usr/bin/env bash

##
## Global config
##
CMAKE_CLI=/usr/bin/cmake
REALPATH_CLI=/usr/bin/realpath
SOURCE_DIR=source
TEMP_ROOT_DIR=temp
TEMP_BUILD_DIR=$TEMP_ROOT_DIR/b
TEMP_INSTALL_DIR=$TEMP_ROOT_DIR/i

##
## Project config
##
PROJECT_GCC_AR_NAME="${MY_PROJECT_GCC_AR_NAME:=ar}"
PROJECT_GCC_C_COMPILER_NAME="${MY_PROJECT_GCC_C_COMPILER_NAME:=gcc-11}"
PROJECT_GCC_CXX_COMPILER_NAME="${MY_PROJECT_GCC_CXX_COMPILER_NAME:=g++-11}"
PROJECT_GCC_LD_NAME="${MY_PROJECT_GCC_LD_NAME:=ld}"
PROJECT_GCC_OS_NAME="${MY_PROJECT_GCC_OS_NAME:=linux}"
PROJECT_REVISION="${BUILD_NUMBER:=9999}"
PROJECT_RELEASE_TYPE="${MY_PROJECT_RELEASE_TYPE:=Debug}"
PROJECT_SHOULD_DISABLE_32BIT_BUILD="${MY_PROJECT_SHOULD_DISABLE_32BIT_BUILD:=OFF}"
PROJECT_SHOULD_DISABLE_64BIT_BUILD="${MY_PROJECT_SHOULD_DISABLE_64BIT_BUILD:=OFF}"
PROJECT_SHOULD_DISABLE_ARM_BUILD="${MY_PROJECT_SHOULD_DISABLE_ARM_BUILD:=OFF}"
PROJECT_SHOULD_DISABLE_X86_BUILD="${MY_PROJECT_SHOULD_DISABLE_X86_BUILD:=OFF}"

##
## My variables
##
MY_CMAKE_COMMON_ARGUMENT_LIST=(
        "-S $SOURCE_DIR"
        "-DCMAKE_SYSTEM_NAME=Linux"
        "-DCMAKE_SYSTEM_PROCESSOR=arm"
        "-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY"
)
declare -A MY_GCC_ARCH_BUILD_TOGGLE_MAP=(
        ["aarch64"]="ON"
        ["arm"]="ON"
        ["x86_64"]="ON"
)
if [ "ON" = "$PROJECT_SHOULD_DISABLE_32BIT_BUILD" ]; then
    MY_GCC_ARCH_BUILD_TOGGLE_MAP["arm"]="OFF"
fi
if [ "ON" = "$PROJECT_SHOULD_DISABLE_64BIT_BUILD" ]; then
    MY_GCC_ARCH_BUILD_TOGGLE_MAP["aarch64"]="OFF"
    MY_GCC_ARCH_BUILD_TOGGLE_MAP["x86_64"]="OFF"
fi
if [ "ON" = "$PROJECT_SHOULD_DISABLE_ARM_BUILD" ]; then
    MY_GCC_ARCH_BUILD_TOGGLE_MAP["aarch64"]="OFF"
    MY_GCC_ARCH_BUILD_TOGGLE_MAP["arm"]="OFF"
fi
if [ "ON" = "$PROJECT_SHOULD_DISABLE_X86_BUILD" ]; then
    MY_GCC_ARCH_BUILD_TOGGLE_MAP["x86_64"]="OFF"
fi



## Print build information
echo "[Linux] Project information: revision:" $PROJECT_REVISION
echo "[Linux] Project information: release type:" $PROJECT_RELEASE_TYPE



## Detect source folder
echo "[Linux] Detecting $SOURCE_DIR folder ..."
if [ ! -d $SOURCE_DIR ] ; then
    echo "[Linux] Detecting $SOURCE_DIR folder ... NOT FOUND"
    exit 1
fi
echo "[Linux] Detecting $SOURCE_DIR folder ... FOUND"



## Clean temp folder
echo "[Linux] Cleaning $TEMP_ROOT_DIR folder ..."
if [ -d $TEMP_ROOT_DIR ] ; then
    echo "[Linux] Removing $TEMP_ROOT_DIR folder ..."
    rm -rf $TEMP_ROOT_DIR 1>/dev/null 2>&1
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Remove $TEMP_ROOT_DIR folder ... FAILED"
        exit 1
    fi
fi
echo "[Linux] Creating $TEMP_BUILD_DIR folder ..."
mkdir -p $TEMP_BUILD_DIR 1>/dev/null 2>&1
MY_CHECK_RESULT=$?
if [ $MY_CHECK_RESULT -ne 0 ] ; then
    echo "[Linux] Creating $TEMP_BUILD_DIR folder ... FAILED"
    exit 1
fi
echo "[Linux] Cleaning $TEMP_BUILD_DIR folder ... DONE"
echo "[Linux] Creating $TEMP_INSTALL_DIR folder ..."
mkdir -p $TEMP_INSTALL_DIR 1>/dev/null 2>&1
MY_CHECK_RESULT=$?
if [ $MY_CHECK_RESULT -ne 0 ] ; then
    echo "[Linux] Creating $TEMP_INSTALL_DIR folder ... FAILED"
    exit 1
fi
echo "[Linux] Cleaning $TEMP_INSTALL_DIR folder ... DONE"



## Detect CMake
echo "[Linux] Detecting CMake ..."
$CMAKE_CLI --help 1>/dev/null 2>&1
MY_CHECK_RESULT=$?
if [ $MY_CHECK_RESULT -ne 0 ] ; then
    echo "[Linux] Detecting CMake ... NOT FOUND"
    exit 1
fi
echo "[Linux] Detecting CMake ... FOUND"



## Detect realpath
echo "[Linux] Detecting realpath ..."
$REALPATH_CLI --help 1>/dev/null 2>&1
MY_CHECK_RESULT=$?
if [ $MY_CHECK_RESULT -ne 0 ] ; then
    echo "[Linux] Detecting realpath ... NOT FOUND"
    exit 1
fi
echo "[Linux] Detecting realpath ... FOUND"



## Build project for architecture x86_64 / gnu
MY_GCC_ABI=gnu
MY_GCC_ARCH=x86_64
echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ..."
if [ "${MY_GCC_ARCH_BUILD_TOGGLE_MAP[$MY_GCC_ARCH]}" = "OFF" ] ; then
    echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ... SKIPPED"
else
    # Define GCC CLI path
    MY_GCC_AR_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_AR_NAME
    MY_GCC_C_COMPILER_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_C_COMPILER_NAME
    MY_GCC_CXX_COMPILER_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_CXX_COMPILER_NAME
    MY_GCC_LD_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_LD_NAME

    # Detect C Compiler
    $MY_GCC_C_COMPILER_CLI --help 1>/dev/null 2>&1
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ... NOT FOUND"
        exit 1
    fi
    echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ... FOUND"

    # Detect CXX Compiler
    echo "[Linux] Detecting CXX Compiler for $MY_GCC_ARCH ..."
    $MY_GCC_CXX_COMPILER_CLI --help 1>/dev/null 2>&1
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Detecting CXX Compiler for $MY_GCC_ARCH ... NOT FOUND"
        exit 1
    fi
    echo "[Linux] Detecting CXX Compiler for $MY_GCC_ARCH ... FOUND"

    # Define build / install path
    MY_TEMP_BUILD_DIR=$TEMP_BUILD_DIR/$PROJECT_RELEASE_TYPE/$MY_GCC_ARCH
    mkdir -p $MY_TEMP_BUILD_DIR
    MY_TEMP_INSTALL_DIR=$TEMP_INSTALL_DIR/$PROJECT_RELEASE_TYPE/$MY_GCC_ARCH
    mkdir -p $MY_TEMP_INSTALL_DIR
    MY_TEMP_INSTALL_DIR_ABS=$($REALPATH_CLI $MY_TEMP_INSTALL_DIR)

    # Generate project
    echo "[Linux] Building project for platform $MY_GCC_ARCH ..."
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ..."
    MY_CMAKE_ARGUMENT_LIST=(
            "-B $MY_TEMP_BUILD_DIR"
            "--install-prefix $MY_TEMP_INSTALL_DIR_ABS"
            "-DCMAKE_AR=$MY_GCC_AR_CLI"
            "-DCMAKE_C_COMPILER=$MY_GCC_C_COMPILER_CLI"
            "-DCMAKE_CXX_COMPILER=$MY_GCC_CXX_COMPILER_CLI"
            "-DCMAKE_LINKER=$MY_GCC_LD_CLI"
    )
    MY_CMAKE_ARGUMENT_LIST=(${MY_CMAKE_COMMON_ARGUMENT_LIST[@]} ${MY_CMAKE_ARGUMENT_LIST[@]})
    MY_CMAKE_ARGUMENT_LIST_STRING=$(IFS=' ' eval 'echo "${MY_CMAKE_ARGUMENT_LIST[*]}"')
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ... argument list:" $MY_CMAKE_ARGUMENT_LIST_STRING
    $CMAKE_CLI $MY_CMAKE_ARGUMENT_LIST_STRING
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ... FAILED (ExitCode: $MY_CHECK_RESULT)"
        exit 1
    fi
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ... DONE"

    # Compile project
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Compiling project ..."
    $CMAKE_CLI --build $MY_TEMP_BUILD_DIR --config $PROJECT_RELEASE_TYPE
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Building project for platform $MY_GCC_ARCH ... Compiling project ... FAILED (ExitCode: $MY_CHECK_RESULT)"
        exit 1
    fi
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Compiling project ... DONE"

    # Install project
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Installing project ..."
    $CMAKE_CLI --install $MY_TEMP_BUILD_DIR --config $PROJECT_RELEASE_TYPE
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Building project for platform $MY_GCC_ARCH ... Installing project ... FAILED (ExitCode: $MY_CHECK_RESULT)"
        exit 1
    fi
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Installing project ... DONE"
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... DONE"
fi



## Build project for architecture arm / gnueabihf
MY_GCC_ABI=gnueabihf
MY_GCC_ARCH=arm
echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ..."
if [ "${MY_GCC_ARCH_BUILD_TOGGLE_MAP[$MY_GCC_ARCH]}" = "OFF" ] ; then
    echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ... SKIPPED"
else
    # Define GCC CLI path
    MY_GCC_AR_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_AR_NAME
    MY_GCC_C_COMPILER_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_C_COMPILER_NAME
    MY_GCC_CXX_COMPILER_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_CXX_COMPILER_NAME
    MY_GCC_LD_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_LD_NAME

    # Detect C Compiler
    $MY_GCC_C_COMPILER_CLI --help 1>/dev/null 2>&1
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ... NOT FOUND"
        exit 1
    fi
    echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ... FOUND"

    # Detect CXX Compiler
    echo "[Linux] Detecting CXX Compiler for $MY_GCC_ARCH ..."
    $MY_GCC_CXX_COMPILER_CLI --help 1>/dev/null 2>&1
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Detecting CXX Compiler for $MY_GCC_ARCH ... NOT FOUND"
        exit 1
    fi
    echo "[Linux] Detecting CXX Compiler for $MY_GCC_ARCH ... FOUND"

    # Define build / install path
    MY_TEMP_BUILD_DIR=$TEMP_BUILD_DIR/$PROJECT_RELEASE_TYPE/$MY_GCC_ARCH
    mkdir -p $MY_TEMP_BUILD_DIR
    MY_TEMP_INSTALL_DIR=$TEMP_INSTALL_DIR/$PROJECT_RELEASE_TYPE/$MY_GCC_ARCH
    mkdir -p $MY_TEMP_INSTALL_DIR
    MY_TEMP_INSTALL_DIR_ABS=$($REALPATH_CLI $MY_TEMP_INSTALL_DIR)

    # Generate project
    echo "[Linux] Building project for platform $MY_GCC_ARCH ..."
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ..."
    MY_CMAKE_ARGUMENT_LIST=(
            "-B $MY_TEMP_BUILD_DIR"
            "--install-prefix $MY_TEMP_INSTALL_DIR_ABS"
            "-DCMAKE_AR=$MY_GCC_AR_CLI"
            "-DCMAKE_C_COMPILER=$MY_GCC_C_COMPILER_CLI"
            "-DCMAKE_CXX_COMPILER=$MY_GCC_CXX_COMPILER_CLI"
            "-DCMAKE_LINKER=$MY_GCC_LD_CLI"
    )
    MY_CMAKE_ARGUMENT_LIST=(${MY_CMAKE_COMMON_ARGUMENT_LIST[@]} ${MY_CMAKE_ARGUMENT_LIST[@]})
    MY_CMAKE_ARGUMENT_LIST_STRING=$(IFS=' ' eval 'echo "${MY_CMAKE_ARGUMENT_LIST[*]}"')
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ... argument list:" $MY_CMAKE_ARGUMENT_LIST_STRING
    $CMAKE_CLI $MY_CMAKE_ARGUMENT_LIST_STRING
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ... FAILED (ExitCode: $MY_CHECK_RESULT)"
        exit 1
    fi
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ... DONE"

    # Compile project
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Compiling project ..."
    $CMAKE_CLI --build $MY_TEMP_BUILD_DIR --config $PROJECT_RELEASE_TYPE
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Building project for platform $MY_GCC_ARCH ... Compiling project ... FAILED (ExitCode: $MY_CHECK_RESULT)"
        exit 1
    fi
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Compiling project ... DONE"

    # Install project
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Installing project ..."
    $CMAKE_CLI --install $MY_TEMP_BUILD_DIR --config $PROJECT_RELEASE_TYPE
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Building project for platform $MY_GCC_ARCH ... Installing project ... FAILED (ExitCode: $MY_CHECK_RESULT)"
        exit 1
    fi
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Installing project ... DONE"
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... DONE"
fi



## Build project for architecture aarch64 / gnu
MY_GCC_ABI=gnu
MY_GCC_ARCH=aarch64
echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ..."
if [ "${MY_GCC_ARCH_BUILD_TOGGLE_MAP[$MY_GCC_ARCH]}" = "OFF" ] ; then
    echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ... SKIPPED"
else
    # Define GCC CLI path
    MY_GCC_AR_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_AR_NAME
    MY_GCC_C_COMPILER_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_C_COMPILER_NAME
    MY_GCC_CXX_COMPILER_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_CXX_COMPILER_NAME
    MY_GCC_LD_CLI=/usr/bin/$MY_GCC_ARCH-$PROJECT_GCC_OS_NAME-$MY_GCC_ABI-$PROJECT_GCC_LD_NAME

    # Detect C Compiler
    $MY_GCC_C_COMPILER_CLI --help 1>/dev/null 2>&1
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ... NOT FOUND"
        exit 1
    fi
    echo "[Linux] Detecting C Compiler for $MY_GCC_ARCH ... FOUND"

    # Detect CXX Compiler
    echo "[Linux] Detecting CXX Compiler for $MY_GCC_ARCH ..."
    $MY_GCC_CXX_COMPILER_CLI --help 1>/dev/null 2>&1
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Detecting CXX Compiler for $MY_GCC_ARCH ... NOT FOUND"
        exit 1
    fi
    echo "[Linux] Detecting CXX Compiler for $MY_GCC_ARCH ... FOUND"

    # Define build / install path
    MY_TEMP_BUILD_DIR=$TEMP_BUILD_DIR/$PROJECT_RELEASE_TYPE/$MY_GCC_ARCH
    mkdir -p $MY_TEMP_BUILD_DIR
    MY_TEMP_INSTALL_DIR=$TEMP_INSTALL_DIR/$PROJECT_RELEASE_TYPE/$MY_GCC_ARCH
    mkdir -p $MY_TEMP_INSTALL_DIR
    MY_TEMP_INSTALL_DIR_ABS=$($REALPATH_CLI $MY_TEMP_INSTALL_DIR)

    # Generate project
    echo "[Linux] Building project for platform $MY_GCC_ARCH ..."
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ..."
    MY_CMAKE_ARGUMENT_LIST=(
            "-B $MY_TEMP_BUILD_DIR"
            "--install-prefix $MY_TEMP_INSTALL_DIR_ABS"
            "-DCMAKE_AR=$MY_GCC_AR_CLI"
            "-DCMAKE_C_COMPILER=$MY_GCC_C_COMPILER_CLI"
            "-DCMAKE_CXX_COMPILER=$MY_GCC_CXX_COMPILER_CLI"
            "-DCMAKE_LINKER=$MY_GCC_LD_CLI"
    )
    MY_CMAKE_ARGUMENT_LIST=(${MY_CMAKE_COMMON_ARGUMENT_LIST[@]} ${MY_CMAKE_ARGUMENT_LIST[@]})
    MY_CMAKE_ARGUMENT_LIST_STRING=$(IFS=' ' eval 'echo "${MY_CMAKE_ARGUMENT_LIST[*]}"')
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ... argument list:" $MY_CMAKE_ARGUMENT_LIST_STRING
    $CMAKE_CLI $MY_CMAKE_ARGUMENT_LIST_STRING
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ... FAILED (ExitCode: $MY_CHECK_RESULT)"
        exit 1
    fi
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Generating project ... DONE"

    # Compile project
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Compiling project ..."
    $CMAKE_CLI --build $MY_TEMP_BUILD_DIR --config $PROJECT_RELEASE_TYPE
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Building project for platform $MY_GCC_ARCH ... Compiling project ... FAILED (ExitCode: $MY_CHECK_RESULT)"
        exit 1
    fi
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Compiling project ... DONE"

    # Install project
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Installing project ..."
    $CMAKE_CLI --install $MY_TEMP_BUILD_DIR --config $PROJECT_RELEASE_TYPE
    MY_CHECK_RESULT=$?
    if [ $MY_CHECK_RESULT -ne 0 ] ; then
        echo "[Linux] Building project for platform $MY_GCC_ARCH ... Installing project ... FAILED (ExitCode: $MY_CHECK_RESULT)"
        exit 1
    fi
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... Installing project ... DONE"
    echo "[Linux] Building project for platform $MY_GCC_ARCH ... DONE"
fi
