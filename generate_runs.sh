#!/usr/bin/env bash

# ========== Usage Check ==========
USAGE="$0 CONFIG INPUT_DIR SOLVER_BINARY [OPTIONS] OUTPUT_CSV"
if [[ $# -eq 4 ]]; then
  OPTIONS=""
  OUTPUT_CSV=${4}
elif [[ $# -eq 5 ]]; then
  OPTIONS=${4}
  OUTPUT_CSV=${5}
else
  echo "[ERROR] $USAGE" >&2
  exit 1
fi

CONFIG=${1?$USAGE}
INPUT_DIR=${2?$USAGE}
SOLVER_BINARY=${3?USAGE}

# ========== Strip trailing slash from input directory ==========
OUT_DIR="./multimod_benchmarks/"

full_bench_path="$OUT_DIR/$INPUT_DIR"

  # Check if benchmark directory exists
if [ ! -d "$full_bench_path" ]; then
  echo "[ERROR] Benchmark directory '$FULL_BENCH_PATH' not found." >&2
  exit 1
fi

# ========== Output CSV Header ==========
echo "benchmark,config,solver,options" > "$OUTPUT_CSV"

  # ========== Find .smt2 files and write to CSV ==========
find "$full_bench_path" -type f \( -name "*.smt2" -o -name "*.out" \) | while read -r abs_path; do

    # Get path relative to current working dir
  benchmark=$(python3 -c "import os; print(os.path.relpath('$abs_path'))")

    # Append row to CSV (no quotes)
  echo $benchmark,$CONFIG,$SOLVER_BINARY,"$OPTIONS" >> "$OUTPUT_CSV"
done

#echo "[DONE]  written to $OUTPUT_CSV"



# # ========== Configurations ==========
# # Each entry is: "logical_name benchmark_subdir solver_binary [options...]"
# # CONFIGS=(
# #     # "ours qf_nia/bv_field range_solver/cvc5/build/bin/cvc5 --mod-range-solver --int-range-or"
# #     # )
  
  
  
  
# #   "cvc5_nia qf_nia/bv_field cvc5/build/bin/cvc5"
# #   "z3_nia qf_nia/bv_field z3/build/z3"
# #   "ours qf_nia/bv_field range_solver/cvc5/build/bin/cvc5 --mod-range-solver --int-range-or"
# #   "z3_bv qf_bv/bv_field z3/build/z3"
# # )

# # ========== Output CSV Header ==========
# echo "benchmark,config,solver,options" > "$OUTPUT_CSV"

# # ========== Process Each Configuration ==========
# for entry in "${CONFIGS[@]}"; do
#   # Split entry into array
#   read -r -a parts <<< "$entry"
#   logical_name="${parts[0]}"
#   bench_subdir="${parts[1]}"
#   solver_binary="${parts[2]}"
#   options="${parts[@]:3}"

#   # Normalize options into a flat space-separated string
#   options=$(printf "%s " $options | sed 's/ *$//')

#   # Build full benchmark directory path
#   full_bench_path="$INPUT_DIR/$bench_subdir"

#   # Check if benchmark directory exists
#   if [ ! -d "$full_bench_path" ]; then
#     echo "[WARN] Skipping config '$logical_name': directory '$full_bench_path' does not exist." >&2
#     continue
#   fi

#   echo "[INFO] Processing config '$logical_name' in '$full_bench_path'..."

#   # ========== Find .smt2 files and write to CSV ==========
#   find "$full_bench_path" -type f \( -name "*.smt2" -o -name "*.out" \) | while read -r abs_path; do

#     # Get path relative to current working dir
#     benchmark=$(python3 -c "import os; print(os.path.relpath('$abs_path'))")

#     # Append row to CSV (no quotes)
#     echo "$benchmark,$logical_name,$solver_binary,$options" >> "$OUTPUT_CSV"
#   done
# done

# echo "[DONE] Output written to $OUTPUT_CSV"
