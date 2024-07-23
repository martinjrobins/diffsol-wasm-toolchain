# derived from https://github.com/olimpiadi-informatica/wasm-compilers/blob/main/Makefile
DIR := $(shell pwd)
#CLANG_VERSION := $(shell /usr/bin/env bash ./llvm_version_major.sh llvm-project)

WASI_SDK := wasi-sdk-22.0
WASI_SDK_PATH := $(DIR)/build/${WASI_SDK}
WASI_SDK_URL := https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-22/wasi-sdk-22.0-linux.tar.gz

# LLVM has some (unreachable in our configuration) calls to mmap.
# Some of the host APIs that are statically required by LLVM (notably threading) are dynamically
# never used. An LTO build removes imports of these APIs, simplifying deployment
WASM_CFLAGS := \
	-D_WASI_EMULATED_MMAN

WASM_CXXFLAGS := \
	-D_WASI_EMULATED_MMAN

# # Compiling C++ code requires a lot of stack space and can overflow and corrupt the heap.
# (For example, `#include <iostream>` alone does it in a build with the default stack size.)
WASM_LDFLAGS := \
	-lwasi-emulated-mman \
	-Wl,--max-memory=4294967296 

NPROCS:=$(shell nproc)

all: build/llvm.BUILT build/llvm-config.BUILT

build:
	mkdir -p build
	
build/wasi-sdk.DOWNLOADED: build
	if [ ! -d build/${WASI_SDK} ]; then curl -L ${WASI_SDK_URL} | tar xzf -; mv wasi-sdk-* build/${WASI_SDK}; fi
	touch $@

build/llvm-src.COPIED: llvm-project | build
	rsync -a --delete llvm-project/ build/llvm-src
	touch $@

build/llvm-host.CONFIG: build/llvm-src.COPIED
	cmake -S build/llvm-src/llvm -B build/llvm-host-build \
		-DCMAKE_INSTALL_PREFIX="${DIR}/build/llvm" \
		-DCMAKE_BUILD_TYPE="MinSizeRel" \
		-DLLVM_TOOL_LLVM_CONFIG_BUILD=ON \
		-DLLVM_TOOL_LLVM_LTO_BUILD=OFF \
		-DLLVM_TOOL_LTO_BUILD=OFF \
		-DLLVM_TOOL_GOLD_BUILD=OFF \
		-DLLVM_TOOL_LLVM_AR_BUILD=OFF \
		-DLLVM_TOOL_LLVM_PROFDATA_BUILD=OFF \
		-DLLVM_TOOL_DSYMUTIL_BUILD=OFF \
		-DLLVM_TOOL_DXIL_DIS_BUILD=OFF \
		-DLLVM_TOOL_LLC_BUILD=OFF \
		-DLLVM_TOOL_LLI_BUILD=OFF \
		-DLLVM_TOOL_LLVM_AS_BUILD=OFF \
		-DLLVM_TOOL_LLVM_AS_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_BCANALYZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_C_TEST_BUILD=OFF \
		-DLLVM_TOOL_LLVM_CAT_BUILD=OFF \
		-DLLVM_TOOL_LLVM_CFI_VERIFY_BUILD=OFF \
		-DLLVM_TOOL_LLVM_COV_BUILD=OFF \
		-DLLVM_TOOL_LLVM_CVTRES_BUILD=OFF \
		-DLLVM_TOOL_LLVM_CXXDUMP_BUILD=OFF \
		-DLLVM_TOOL_LLVM_CXXFILT_BUILD=OFF \
		-DLLVM_TOOL_LLVM_CXXMAP_BUILD=OFF \
		-DLLVM_TOOL_LLVM_DEBUGINFO_ANALYZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_DEBUGINFOD_BUILD=OFF \
		-DLLVM_TOOL_LLVM_DEBUGINFOD_FIND_BUILD=OFF \
		-DLLVM_TOOL_LLVM_DIFF_BUILD=OFF \
		-DLLVM_TOOL_LLVM_DIS_BUILD=OFF \
		-DLLVM_TOOL_LLVM_DIS_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_DLANG_DEMANGLE_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_DWARFDUMP_BUILD=OFF \
		-DLLVM_TOOL_LLVM_DWP_BUILD=OFF \
		-DLLVM_TOOL_LLVM_EXEGESIS_BUILD=OFF \
		-DLLVM_TOOL_LLVM_EXTRACT_BUILD=OFF \
		-DLLVM_TOOL_LLVM_GSYMUTIL_BUILD=OFF \
		-DLLVM_TOOL_LLVM_IFS_BUILD=OFF \
		-DLLVM_TOOL_LLVM_ISEL_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_ITANIUM_DEMANGLE_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_JITLINK_BUILD=OFF \
		-DLLVM_TOOL_LLVM_LIBTOOL_DARWIN_BUILD=OFF \
		-DLLVM_TOOL_LLVM_LINK_BUILD=OFF \
		-DLLVM_TOOL_LLVM_LIPO_BUILD=OFF \
		-DLLVM_TOOL_LLVM_LTO2_BUILD=OFF \
		-DLLVM_TOOL_LLVM_MC_BUILD=OFF \
		-DLLVM_TOOL_LLVM_MC_ASSEMBLE_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_MC_DISASSEMBLE_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_MCA_BUILD=OFF \
		-DLLVM_TOOL_LLVM_MICROSOFT_DEMANGLE_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_ML_BUILD=OFF \
		-DLLVM_TOOL_LLVM_MODEXTRACT_BUILD=OFF \
		-DLLVM_TOOL_LLVM_MT_BUILD=OFF \
		-DLLVM_TOOL_LLVM_NM_BUILD=OFF \
		-DLLVM_TOOL_LLVM_OBJCOPY_BUILD=OFF \
		-DLLVM_TOOL_LLVM_OBJDUMP_BUILD=OFF \
		-DLLVM_TOOL_LLVM_OPT_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_OPT_REPORT_BUILD=OFF \
		-DLLVM_TOOL_LLVM_PDBUTIL_BUILD=OFF \
		-DLLVM_TOOL_LLVM_PROFGEN_BUILD=OFF \
		-DLLVM_TOOL_LLVM_RC_BUILD=OFF \
		-DLLVM_TOOL_LLVM_READOBJ_BUILD=OFF \
		-DLLVM_TOOL_LLVM_READTAPI_BUILD=OFF \
		-DLLVM_TOOL_LLVM_REDUCE_BUILD=OFF \
		-DLLVM_TOOL_LLVM_REMARKUTIL_BUILD=OFF \
		-DLLVM_TOOL_LLVM_RTDYLD_BUILD=OFF \
		-DLLVM_TOOL_LLVM_RUST_DEMANGLE_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_SIM_BUILD=OFF \
		-DLLVM_TOOL_LLVM_SIZE_BUILD=OFF \
		-DLLVM_TOOL_LLVM_SPECIAL_CASE_LIST_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_SPLIT_BUILD=OFF \
		-DLLVM_TOOL_LLVM_STRESS_BUILD=OFF \
		-DLLVM_TOOL_LLVM_STRINGS_BUILD=OFF \
		-DLLVM_TOOL_LLVM_SYMBOLIZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_TLI_CHECKER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_UNDNAME_BUILD=OFF \
		-DLLVM_TOOL_LLVM_XRAY_BUILD=OFF \
		-DLLVM_TOOL_LLVM_YAML_NUMERIC_PARSER_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_LLVM_YAML_PARSER_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_OBJ2YAML_BUILD=OFF \
		-DLLVM_TOOL_OPT_BUILD=OFF \
		-DLLVM_TOOL_OPT_VIEWER_BUILD=OFF \
		-DLLVM_TOOL_REDUCE_CHUNK_LIST_BUILD=OFF \
		-DLLVM_TOOL_REMARKS_SHLIB_BUILD=OFF \
		-DLLVM_TOOL_SANCOV_BUILD=OFF \
		-DLLVM_TOOL_SANSTATS_BUILD=OFF \
		-DLLVM_TOOL_SPIRV_TOOLS_BUILD=OFF \
		-DLLVM_TOOL_VERIFY_USELISTORDER_BUILD=OFF \
		-DLLVM_TOOL_VFABI_DEMANGLE_FUZZER_BUILD=OFF \
		-DLLVM_TOOL_XCODE_TOOLCHAIN_BUILD=OFF \
		-DLLVM_TOOL_YAML2OBJ_BUILD=OFF \
		-DLLVM_INCLUDE_RUNTIMES=OFF \
		-DLLVM_INCLUDE_BENCHMARKS=OFF \
		-DLLVM_INCLUDE_EXAMPLES=OFF \
		-DLLVM_INCLUDE_TESTS=OFF \
  	-DLLVM_INCLUDE_UTILS=OFF \
		-DLLVM_INCLUDE_DOCS=OFF \
		-DLLVM_ENABLE_PROJECTS=""
	touch $@

build/llvm.CONFIG: build/llvm-src.COPIED | build/wasi-sdk.DOWNLOADED
	cmake -S build/llvm-src/llvm -B build/llvm-build \
		-DCMAKE_INSTALL_PREFIX="${DIR}/build/llvm" \
		-DCMAKE_BUILD_TYPE="MinSizeRel" \
		-DCMAKE_TOOLCHAIN_FILE="${DIR}/cmake/toolchain.cmake" \
		-DCMAKE_C_FLAGS="-I${DIR} ${WASM_CFLAGS}" \
		-DCMAKE_CXX_FLAGS="-I${DIR} ${WASM_CXXFLAGS} -fno-exceptions" \
		-DCMAKE_EXE_LINKER_FLAGS="${WASM_LDFLAGS}" \
		-DWASI_SDK_PREFIX="${WASI_SDK_PATH}" \
		-DLLVM_TARGETS_TO_BUILD="WebAssembly" \
		-DLLVM_DEFAULT_TARGET_TRIPLE=wasm32-wasi-threads \
		-DLLVM_ENABLE_LTO=ON \
		-DLLVM_ENABLE_PIC=OFF \
		-DLLVM_INCLUDE_TOOLS=OFF \
		-DLLVM_INCLUDE_RUNTIMES=OFF \
		-DLLVM_INCLUDE_BENCHMARKS=OFF \
		-DLLVM_INCLUDE_EXAMPLES=OFF \
		-DLLVM_INCLUDE_TESTS=OFF \
  	-DLLVM_INCLUDE_UTILS=OFF \
		-DLLVM_INCLUDE_DOCS=OFF \
		-DLLVM_ENABLE_PROJECTS=""
	touch $@

build/llvm-config.BUILT: build/llvm-host.CONFIG
	cmake --build build/llvm-host-build --target llvm-config -j ${NPROCS}
	cp build/llvm-host-build/bin/llvm-config build/llvm/bin/
	touch $@
	
build/llvm.BUILT: build/llvm.CONFIG
	cmake --build build/llvm-build --target install -j ${NPROCS}
	touch $@

clean:
	rm -rf build/

.PHONY: all clean