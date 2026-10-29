#!/usr/bin/env bash
set -euo pipefail

CURRENT_PID=""
cleanup() {
  if [[ -n "$CURRENT_PID" ]]; then
    kill "$CURRENT_PID" 2>/dev/null || true
    wait "$CURRENT_PID" 2>/dev/null || true
  fi
  exit 130
}
trap cleanup INT TERM

BUILD_DIR="${1:-build-fuzz}"
MAX_TIME="${2:-30}"
MAX_LEN="${3:-4096}"
SANITIZERS="${FUZZ_SANITIZERS:-fuzzer,address,undefined}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [[ "$(uname)" == "Darwin" ]]; then
  LLVM_PREFIX="$(brew --prefix llvm 2>/dev/null || true)"
  QT_PREFIX="$(brew --prefix qt 2>/dev/null || true)"
  if [[ -z "$LLVM_PREFIX" || -z "$QT_PREFIX" ]]; then
    echo "Missing Homebrew llvm/qt. Install with: brew install llvm qt cmake" >&2
    exit 1
  fi
  CXX_COMPILER="$LLVM_PREFIX/bin/clang++"
  SYSROOT="$(xcrun --show-sdk-path)"
  EXTRA_CMAKE_ARGS=(
    -DCMAKE_OSX_SYSROOT="$SYSROOT"
    -DQt6_DIR="$QT_PREFIX/lib/cmake/Qt6"
  )
else
  CXX_COMPILER="${CXX_COMPILER:-clang++}"
  EXTRA_CMAKE_ARGS=()
fi

echo "Configuring in $BUILD_DIR ..."
cmake -S . -B "$BUILD_DIR" \
  -DCMAKE_CXX_COMPILER="$CXX_COMPILER" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DENABLE_IPC=OFF \
  -DBUILD_FUZZ_TESTS=ON \
  -DBUILD_APP_TESTS=OFF \
  -DFUZZ_SANITIZERS="$SANITIZERS" \
  "${EXTRA_CMAKE_ARGS[@]}"

echo "Building ..."
cmake --build "$BUILD_DIR" --parallel

echo "Running fuzz targets (max ${MAX_TIME}s each) ..."
for f in "$BUILD_DIR"/test/fuzz/fuzz_*; do
  [[ -f "$f" && -x "$f" ]] || continue
  name="$(basename "$f")"
  corpus_dir="$BUILD_DIR/test/fuzz/corpus/$name"
  mkdir -p "$corpus_dir"
  dict_arg=""
  if [[ -f "test/fuzz/dicts/$name.dict" ]]; then
    dict_arg="-dict=test/fuzz/dicts/$name.dict"
  fi
  echo "===== $name ====="
  env ASAN_OPTIONS=detect_leaks=0 \
      TSAN_OPTIONS="suppressions=$ROOT_DIR/test/sanitizer_suppressions/tsan" \
    "$f" "$corpus_dir" $dict_arg -max_total_time="$MAX_TIME" -max_len="$MAX_LEN" &
  CURRENT_PID=$!
  wait "$CURRENT_PID" || true
  CURRENT_PID=""
done

echo "Done."
