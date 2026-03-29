#!/usr/bin/env bash
set -euo pipefail

show_errors=0
new_style=0
stdout_file=""
stderr_file=""
timeit=""
timeout_sec=""

usage() {
  echo "Usage:"
  echo "  RunSafely.sh [-n] [-o <stdoutfile>] [-e <stderrfile>] [--show-errors] -t <timeit> <timeout> <infile> <outfile> <program> <args...>"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n)
      new_style=1
      shift
      ;;
    -o)
      stdout_file="$2"
      shift 2
      ;;
    -e)
      stderr_file="$2"
      shift 2
      ;;
    --show-errors)
      show_errors=1
      shift
      ;;
    -t)
      timeit="$2"
      shift 2
      break
      ;;
    *)
      usage
      ;;
  esac
done

[[ -n "${timeit}" ]] || usage
[[ $# -ge 4 ]] || usage

timeout_sec="$1"
infile="$2"
outfile="$3"
shift 3

program="$1"
shift
args=("$@")

mkdir -p "$(dirname "${outfile}")"

if [[ "${new_style}" -eq 1 ]]; then
  : "${stdout_file:?Need -o <stdoutfile> with -n}"
  : "${stderr_file:?Need -e <stderrfile> with -n}"
  mkdir -p "$(dirname "${stdout_file}")" "$(dirname "${stderr_file}")"

  set +e
  timeout "${timeout_sec}" "${timeit}" -p -o "${outfile}.time" \
    "${program}" "${args[@]}" < "${infile}" > "${stdout_file}" 2> "${stderr_file}"
  exit_code=$?
  set -e

  echo "${exit_code}" > "${outfile}.exit"

  if [[ "${show_errors}" -eq 1 && "${exit_code}" -ne 0 ]]; then
    echo "=== COMMAND FAILED (exit ${exit_code}) ===" >&2
    echo "--- stderr ---" >&2
    cat "${stderr_file}" >&2 || true
    echo "--- stdout ---" >&2
    cat "${stdout_file}" >&2 || true
  fi

  exit "${exit_code}"
else
  set +e
  timeout "${timeout_sec}" "${timeit}" -p -o "${outfile}.time" \
    "${program}" "${args[@]}" < "${infile}" > "${outfile}" 2>&1
  exit_code=$?
  set -e

  echo "exit ${exit_code}" >> "${outfile}"

  if [[ "${show_errors}" -eq 1 && "${exit_code}" -ne 0 ]]; then
    cat "${outfile}" >&2 || true
  fi

  exit "${exit_code}"
fi
