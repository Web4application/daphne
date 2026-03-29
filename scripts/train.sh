#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${ROOT}/build/train"
RESULTS="${ROOT}/results/train"
PROFILES="${BUILD}/profiles"

mkdir -p "${BUILD}" "${RESULTS}/stdout" "${RESULTS}/stderr" "${RESULTS}/timing"

cmake -S "${ROOT}" -B "${BUILD}" \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_BUILD_TYPE=Release \
  -DPGO_GENERATE=ON

cmake --build "${BUILD}" -j

# LLVM profile raw output file location
export LLVM_PROFILE_FILE="${PROFILES}/sort_bench.profraw"
mkdir -p "${PROFILES}"

"${ROOT}/scripts/RunSafely.sh" \
  -n \
  -o "${RESULTS}/stdout/sort_train.out" \
  -e "${RESULTS}/stderr/sort_train.err" \
  --show-errors \
  -t /usr/bin/time \
  10 \
  "${ROOT}/inputs/train.in" \
  "${RESULTS}/timing/sort_train" \
  "${BUILD}/sort_bench"

# Merge raw profile into profdata
llvm-profdata merge -output="${PROFILES}/default.profdata" "${PROFILES}/sort_bench.profraw"

echo "Training profile created:"
echo "  ${PROFILES}/default.profdata"
