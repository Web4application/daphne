#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TRAIN_BUILD="${ROOT}/build/train"
USE_BUILD="${ROOT}/build/use"
RESULTS="${ROOT}/results/use"
PROFDATA="${TRAIN_BUILD}/profiles/default.profdata"

if [[ ! -f "${PROFDATA}" ]]; then
  echo "Missing profile data: ${PROFDATA}" >&2
  echo "Run scripts/train-pgo.sh first." >&2
  exit 1
fi

mkdir -p "${USE_BUILD}" "${RESULTS}/stdout" "${RESULTS}/stderr" "${RESULTS}/timing"

cmake -S "${ROOT}" -B "${USE_BUILD}" \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_BUILD_TYPE=Release \
  -DPGO_USE=ON \
  -DPGO_PROFILE_FILE="${PROFDATA}"

cmake --build "${USE_BUILD}" -j

"${ROOT}/scripts/RunSafely.sh" \
  -n \
  -o "${RESULTS}/stdout/sort_ref.out" \
  -e "${RESULTS}/stderr/sort_ref.err" \
  --show-errors \
  -t /usr/bin/time \
  10 \
  "${ROOT}/inputs/ref.in" \
  "${RESULTS}/timing/sort_ref" \
  "${USE_BUILD}/sort_bench"

echo "PGO benchmark complete."
echo "Outputs:"
echo "  stdout: ${RESULTS}/stdout/sort_ref.out"
echo "  stderr: ${RESULTS}/stderr/sort_ref.err"
echo "  timing: ${RESULTS}/timing/sort_ref.time"
echo "  exit:   ${RESULTS}/timing/sort_ref.exit"
