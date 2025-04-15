import pandas as pd
import re
import sys


if len(sys.argv) < 2:
    print("Usage: python analyze.py runs.csv", file=sys.stderr)
    sys.exit(1)


input_file = sys.argv[1]

df = pd.read_csv(input_file)
df.columns = df.columns.str.strip()

def transform_name(benchmark):
    if benchmark is None:
        return benchmark
    benchmark = benchmark.replace("mp_field/o1js_cor/", "ff(m)/cor")
    benchmark = benchmark.replace("montgomery/mp", "fb(m)/cor")
    benchmark = benchmark.replace("montgomery/sp", "fb(s)/cor")
    benchmark = benchmark.replace("sp_field/goldilocks_cor", "ff(s)/cor")
    benchmark = benchmark.replace("sp_field/goldilocks_det", "ff(s)/det")
    benchmark = benchmark.replace("bv_field", "bf(s)")
    return benchmark

# Normalize benchmark path for uniqueness
def extract_info(row):
    benchmark = row['benchmark']
    config = row['config']
    solver = config

    # Strip extensions
    benchmark = re.sub(r'\.smt2(\.out)?$', '.smt2', benchmark)
    benchmark = benchmark.replace("mp_field/o1js_cor/", "ff(m)/cor")
    benchmark = benchmark.replace("montgomery/mp", "fb(m)/cor")
    benchmark = benchmark.replace("montgomery/sp", "fb(s)/cor")
    benchmark = benchmark.replace("sp_field/goldilocks_cor", "ff(s)/cor")
    benchmark = benchmark.replace("sp_field/goldilocks_det", "ff(s)/det")
    benchmark = benchmark.replace("sp_field/goldilocks_det", "ff(s)/det")

    parts = benchmark.split('/')
    if len(parts) < 5:
        return pd.Series([None, None, None, None])  # malformed

    logic = parts[1]      # e.g., qf_nia
    family = parts[2]     # e.g., bv_field
    bench_type = parts[3] # e.g., det
    name = parts[4:len(parts)]       # e.g., add_det_32b_4l_2l_nia.smt2

    normalized_path = f"{name}"
    solver_full = solver

    return pd.Series([normalized_path, solver_full, family, bench_type])

df[['norm_benchmark', 'solver', 'family', 'type']] = df.apply(extract_info, axis=1)

# ----------------------------
# Compute total benchmarks overall (de-duped)
# ----------------------------
unique_benchmarks = df[['norm_benchmark', 'family', 'type']].drop_duplicates()
total_per_family_type = unique_benchmarks.groupby(['family', 'type']).size()

# ----------------------------
# Compute unsat counts per solver
# ----------------------------
unsat_only = df[df['result'] == 'unsat']
unsat_counts = unsat_only.pivot_table(
    index='solver',
    columns=['family', 'type'],
    aggfunc='size',
    fill_value=0
)

# Add total row
for (fam, typ), count in total_per_family_type.items():
    unsat_counts.loc['Total Benchmarks', (fam, typ)] = count

unsat_counts = unsat_counts.fillna(0).astype(int)

# Save and print
unsat_counts.to_csv("unsat_by_solver.csv")
print(unsat_counts)
