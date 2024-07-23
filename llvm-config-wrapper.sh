#!/usr/bin/env bash

# call llvm-config with the arguments passed to this script
# if arg is "--cflags" then append "--sysroot=$SCRIPT_DIR/../wasi-sdk-22.0/share/wasi-sysroot" to the output
SCRIPT_DIR=$(dirname $0)
LLVM_CONFIG=$SCRIPT_DIR/llvm-config-host
SCRIPT_DIR_ESCAPED=$(echo $SCRIPT_DIR | sed 's/\//\\\//g')

if [ "$1" == "--cflags" ]; then
    $LLVM_CONFIG ${@:1} | sed "s/$/ --sysroot=$SCRIPT_DIR_ESCAPED\/..\/wasi-sdk-22.0\/share\/wasi-sysroot/"
else
    $LLVM_CONFIG ${@:1}
fi

