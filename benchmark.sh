#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RESULTS="${ROOT}/benchmarks/results"
mkdir -p "${RESULTS}/stdout" "${RESULTS}/stderr" "${RESULTS}/timing"

declare -a COMMANDS=(
    "doctor"
    "init"
    "run benchmarks/inputs/workflow_demo.yaml"
)

rm -f "${RESULTS}/result.json"
echo "[" > "${RESULTS}/result.json"

for cmd in "${COMMANDS[@]}"; do
    base_name=$(echo "${cmd}" | tr ' ' '_' | tr '/' '_')
    ./scripts/RunSafely.sh \
        -o "${RESULTS}/stdout/${base_name}.out" \
        -e "${RESULTS}/stderr/${base_name}.err" \
        --show-errors \
        -t 30 \
        /dev/null \
        "${RESULTS}/timing/${base_name}" \
        pwsh -File "${ROOT}/bin/daphne.ps1" ${cmd}

    real_time=$(grep "^real" "${RESULTS}/timing/${base_name}.time" | awk '{print $2}')
    exit_code=$(cat "${RESULTS}/timing/${base_name}.exit")

    echo "  {\"command\": \"${cmd}\", \"real_time\": ${real_time}, \"exit_code\": ${exit_code}, \"stdout\": \"stdout/${base_name}.out\", \"stderr\": \"stderr/${base_name}.err\"}," >> "${RESULTS}/result.json"
done

# remove last comma
sed -i '$ s/,$//' "${RESULTS}/result.json"
echo "]" >> "${RESULTS}/result.json"

echo "Benchmark complete! Results in ${RESULTS}/result.json"
