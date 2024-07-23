# diffsol-wasm-toolchain

Just run the Makefile in the root dir to build everything.

```sh
make
```

The llvm build is in `build/llvm`, all the libraries are compiled to `wasm32-wasi-threads` target, and `llvm-config` is compiled as a host executable (not wasm).

