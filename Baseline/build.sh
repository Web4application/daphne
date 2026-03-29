#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE_BUILD="${ROOT}/build/base"
BASE_RESULTS="${ROOT}/results/base"
USE_RESULTS="${ROOT}/results/use"

mkdir -p "${BASE_BUILD}" "${BASE_RESULTS}/stdout" "${BASE_RESULTS}/stderr" "${BASE_RESULTS}/timing"

# Build baseline (no PGO)
cmake -S "${ROOT}" -B "${BASE_BUILD}" \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_BUILD_TYPE=Release

cmake --build "${BASE_BUILD}" -j

"${ROOT}/scripts/RunSafely.sh" \
  -n \
  -o "${BASE_RESULTS}/stdout/sort_ref.out" \
  -e "${BASE_RESULTS}/stderr/sort_ref.err" \
  --show-errors \
  -t /usr/bin/time \
  10 \
  "${ROOT}/inputs/ref.in" \
  "${BASE_RESULTS}/timing/sort_ref" \
  "${BASE_BUILD}/sort_bench"

echo
echo "=== Baseline timing ==="
cat "${BASE_RESULTS}/timing/sort_ref.time" || true

echo
echo "=== PGO timing ==="
cat "${USE_RESULTS}/timing/sort_ref.time" || true
