# Fuzzing Framework

This directory contains fuzzing targets and tooling for the QML application's
C++ backend. Fuzz targets are built with libFuzzer and run under AddressSanitizer
and UndefinedBehaviorSanitizer.

## Building

On macOS (Homebrew):

```sh
./test/fuzz/build.sh
```

Or manually:

```sh
cmake -S . -B build-fuzz -G Ninja \
  -DCMAKE_CXX_COMPILER="$(brew --prefix llvm)/bin/clang++" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DBUILD_FUZZ_TESTS=ON \
  -DBUILD_APP_TESTS=OFF
cmake --build build-fuzz --parallel
```

On Ubuntu CI, see `.github/workflows/fuzz.yml`.

## Running

```sh
ASAN_OPTIONS=detect_leaks=0 ./build-fuzz/test/fuzz/fuzz_bitcoin_uri corpus/ -max_total_time=60
```

## Static analysis

```sh
python3 test/fuzz/qml_security_lint.py qml
```

## Targets

- `fuzz_bitcoin_uri` - fuzzes `BitcoinUri::Parse`
- `fuzz_bitcoin_address` - fuzzes `BitcoinAddress::setAddress`
- `fuzz_bitcoin_amount` - fuzzes `BitcoinAmount::fromDisplay`
- `fuzz_qml_datadir` - fuzzes `QmlDataDir` path validation/normalization
- `fuzz_bitcoin_units` - fuzzes `QmlBitcoinUnits` formatting/labels
