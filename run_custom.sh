#!/usr/bin/env bash

# ========== Helper: Print Options ==========
if [[ "$1" == "-o" ]]; then
  echo "Available solvers:"
  echo "  ours_nia"
  echo "  z3_nia"
  echo "  yices_nia"
  echo "  z3_bv"
  echo "  cvc5_bv"
  echo "  bitwuzla_bv"
  echo "  bitwuzla_bv_abst"
  echo "  cvc5_ff_splitGB"
  echo "  cvc5_ff"
  echo "  yices_ff"
  echo
  echo "Available families/types:"
  echo "  fb(s)/cor"
  echo "  fb(m)/cor"
  echo "  ff(s)/cor"
  echo "  ff(s)/det"
  echo "  ff(m)/cor"
  echo "  bf(m)/cor"
  echo "  bf(m)/det"
  exit 0
fi

# ========== Usage Check ==========
USAGE="$0 SOLVER FAMILY/TYPE TIMEOUT NUM_JOBS"
SOLVER=${1?$USAGE}
FAMILY_TYPE=${2?$USAGE}
export LIMIT_TIME=${3?$USAGE}
N=${4?$USAGE}

# ========== Paths ==========
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export BENCHMARK_DIR="$SCRIPT_DIR"
CSV_FILE="$SCRIPT_DIR/tmp_benchmark_list.csv"

# Optional: assume 4GB per job as default memory model
export LIMIT_MEM=$((N * 4096))

# ========== Generate Benchmark List ==========
echo "[INFO] Generating CSV for solver=$SOLVER, family=$FAMILY_TYPE..."

echo "benchmark,config,solver,options" > "$CSV_FILE"

# --------- Configuration for known solvers ----------
case "$SOLVER" in
  ours_mia)
    SOLVER_BIN="range_solver/cvc5/build/bin/cvc5"
    SOLVER_OPTS="--mod-range-solver --int-range-or"
    LOGIC_DIR="qf_nia"
    ;;
  z3_nia)
    SOLVER_BIN="z3/build/z3"
    SOLVER_OPTS=""
    LOGIC_DIR="qf_nia"
    ;;
  cvc5_nia)
    SOLVER_BIN="cvc5/build/bin/cvc5"
    SOLVER_OPTS=""
    LOGIC_DIR="qf_nia"
    ;;
  yices_nia)
    SOLVER_BIN="yices2/build/aarch64-unknown-linux-gnu-release/bin/yices_smt2"
    SOLVER_OPTS=""
    LOGIC_DIR="qf_nia"
    ;;
  z3_bv)
    SOLVER_BIN="z3/build/z3"
    SOLVER_OPTS=""
    LOGIC_DIR="qf_bv"
    ;;
  cvc5_bv)
    SOLVER_BIN="cvc5/build/bin/cvc5"
    SOLVER_OPTS=""
    LOGIC_DIR="qf_bv"
    ;;
  bitwuzla_bv)
    SOLVER_BIN="bitwuzla/build/src/main/bitwuzla"
    SOLVER_OPTS=""
    LOGIC_DIR="qf_bv"
    ;;
  bitwuzla_bv_abst)
    SOLVER_BIN="bitwuzla/build/bitwuzla"
    SOLVER_OPTS="--abstraction"
    LOGIC_DIR="qf_bv"
    ;;
  cvc5_ff)
    SOLVER_BIN="ff/cvc5/build/bin/cvc5"
    SOLVER_OPTS=""
    LOGIC_DIR="qf_ff"
    ;;
  cvc5_ff_splitGB)
    SOLVER_BIN="cvc5/build/bin/cvc5"
    SOLVER_OPTS="--ff-solver=split"
    LOGIC_DIR="qf_ff"
    ;;
  yices_ff)
    SOLVER_BIN="yices2/build/aarch64-unknown-linux-gnu-release/bin/yices_smt2"
    SOLVER_OPTS=""
    LOGIC_DIR="qf_ffa"
    ;;
  *)
    echo "[ERROR] Unknown solver: $SOLVER"
    echo "Run with -o to see available options."
    exit 1
    ;;
esac

# --------- Configuration for known families ----------
case "$FAMILY_TYPE" in
  "fb(s)/cor")
    FAMILY_DIR="montgomery/sp"
    ;;
  "fb(m)/cor")
    FAMILY_DIR="montgomery/mp"
    ;;
  "ff(s)/cor")
    FAMILY_DIR="sp_field/goldilocks_cor"
    ;;
  "ff(s)/det")
    FAMILY_DIR="sp_field/goldilocks_det"
    ;;
  "ff(m)/cor")
    FAMILY_DIR="mp_field/o1js_cor"
    ;;
  "bf(m)/cor")
    FAMILY_DIR="bv_field/cor"
    ;;
  "bf(m)/det")
    FAMILY_DIR="bv_field/det"
    ;;
     *)
    echo "[ERROR] Unknown family_type: $FAMILY_TYPE"
    echo "Run with -o to see available options."
    exit 1
esac

FULL_BENCH_PATH="$LOGIC_DIR/$FAMILY_DIR"

# logic we should generate a run script file first 
#echo "./generate_runs.sh $SOLVER $FULL_BENCH_PATH $SOLVER_OPTS custom_runs.csv"
./generate_runs.sh $SOLVER $FULL_BENCH_PATH $SOLVER_BIN "$SOLVER_OPTS" "custom_bench.csv"




export LIMIT_MEM=8000
export BENCHMARK_DIR="."

export PATH=$(pwd)/runlim/:$PATH



echo benchmark,config,status,result,exit_code,time_cpu,memory > custom_runs.csv
#echo "N is $N"
# Run jobs in parallel, skipping header
#echo "time tail -n +2 "custom_bench.csv" | parallel --eta -j "$N" ./run_solver.py >> custom_runs.csv"
time tail -n +2 "custom_bench.csv" | parallel --eta -j "$N" ./run_solver.py >> custom_runs.csv

#echo "[INFO] finished running benchmarks"

python3 analyze.py custom_runs.csv

# and then we should feed it into ./run_some.sh script lol 