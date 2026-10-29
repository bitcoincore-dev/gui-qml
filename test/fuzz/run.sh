#!/usr/bin/env bash
# Run every locally-built fuzz target for a short time.
# Usage: ./test/fuzz/run.sh [seconds_per_target]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

TIME_PER_TARGET="${1:-30}"
BUILD_DIR="${BUILD_DIR:-build-fuzz}"

if [ ! -d "$BUILD_DIR/test/fuzz" ]; then
    echo "No fuzz binaries found in $BUILD_DIR/test/fuzz. Run ./test/fuzz/build.sh first."
    exit 1
fi

ASAN_OPTIONS=detect_leaks=0
export ASAN_OPTIONS

for f in "$BUILD_DIR"/test/fuzz/fuzz_*; do
    [ -x "$f" ] || continue
    name=$(basename "$f")
    corpus_dir="$BUILD_DIR/test/fuzz/corpus/$name"
    mkdir -p "$corpus_dir"
    dict_arg=""
    if [ -f "test/fuzz/dicts/$name.dict" ]; then
        dict_arg="-dict=test/fuzz/dicts/$name.dict"
    fi
    echo "=== Running $name (${TIME_PER_TARGET}s) ==="
    "$f" "$corpus_dir" $dict_arg -max_total_time="$TIME_PER_TARGET" || true
done
