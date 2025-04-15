#!/usr/bin/env bash

USAGE="$0 NUM_PROCESSORS"
N=${1?$USAGE}
export LIMIT_TIME=1200
export LIMIT_MEM=8000
CSV_FILE=large_bench.csv
export BENCHMARK_DIR="."

export PATH=$(pwd)/runlim/:$PATH

set -e

echo benchmark,config,status,result,exit_code,time_cpu,memory > runs.csv

# Run jobs in parallel, skipping header
time tail -n +2 "$CSV_FILE" | parallel --eta -j "$N" ./run_solver.py >> runs.csv

python3 analyze.py runs.csv