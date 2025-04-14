#!/usr/bin/env bash

USAGE="$0 NUM_PROCESSORS LIMIT_TIME LIMIT_MEM_PER_CPU CSV_FILE BENCHMARK_DIR"
N=${1?$USAGE}
export LIMIT_TIME=${2?$USAGE}
export LIMIT_MEM=${3?$USAGE}
CSV_FILE=${4?$USAGE}
export BENCHMARK_DIR=${5?$USAGE}

export PATH=$(pwd)/runlim/:$PATH

set -e

echo benchmark,config,status,result,exit_code,time_cpu,memory > runs.csv

# Run jobs in parallel, skipping header
time tail -n +2 "$CSV_FILE" | parallel --eta -j "$N" ./run_solver.py >> runs.csv
