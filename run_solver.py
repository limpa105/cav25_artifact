#!/usr/bin/env python3

import sys
import os
import subprocess as sub
import time
import shutil
import re
import tempfile

try:
    benchmark, config, solver, options = sys.argv[1].split(",")
except Exception:
    print("Usage: run_solver.py FILE,CONFIG,SOLVER,OPTIONS", file=sys.stderr)
    sys.exit(2)

with tempfile.NamedTemporaryFile() as t:
    limit_time = os.environ["LIMIT_TIME"]
    limit_mem = os.environ["LIMIT_MEM"]
    benchmark_dir = os.environ["BENCHMARK_DIR"]
    benchmark_dir = os.path.abspath(benchmark_dir)
    options = options.replace('"', '')
    #benchmark_dir = "."
    #assert os.path.exists(f"{benchmark_dir}/smt2")
    #assert os.path.exists(f"{benchmark_dir}/circ_ir")
    benchmark = benchmark.replace("*", "\\*")
    solver_command = ""
    if(options == ""):
        #solver_command = f" {solver} --tlimit 2000 {benchmark} >> {t.name}"
        solver_command = f"./runlim -s {limit_mem} -r {limit_time} -o {t.name} {solver} {benchmark}"
    else:
        #solver_command = f" {solver} {options} --tlimit 2000 {benchmark} >> {t.name}"
        solver_command = f"./runlim -s {limit_mem} -r {limit_time} -o {t.name} {solver} {options} {benchmark}"
    #print("KILL ME")
    #solver_command = f"./runlim -s {limit_mem} -r {limit_time} -o {t.name} {solver} {options} {benchmark}"
    #solver_command = f" {solver} {options} --tlimit 2000 {benchmark}"
    def print_command():
        print(f"cd {benchmark_dir} && PATH={os.environ['PATH']} {solver_command}", file=sys.stderr)
    try:
        start = time.time()
        os.makedirs("log", exist_ok=True)
        o = sub.run(solver_command, cwd=benchmark_dir, stdout=sub.PIPE, stderr=sub.PIPE, shell=True)
        log = open(t.name).read()
        status = re.search("status:\\s*(\\S.*)", log)[1]
        statuses = {"ok": "ok", "out of memory": "mo", "out of time": "to"}
        status = statuses[status]
        if re.search("\\bunsat", o.stdout.decode()):
            result = "unsat"
        elif re.search("\\bsat", o.stdout.decode()):
            result = "sat"
        elif re.search("\\bunknown", o.stdout.decode()):
            result = "unknown"
        else:
            result = "unknown"
        end = time.time()
        exit_code = int(re.search("result:\\s*(\\S.*)", log)[1])
        if status not in statuses.values() and exit_code != 0:
            status = "ee"
        if status == "ee":
            print(o.stdout.decode(), file=sys.stderr)
            print(o.stderr.decode(), file=sys.stderr)
        walltime = float(re.search("real:\\s*(\\S*)", log)[1])
        cputime = float(re.search("time:\\s*(\\S*)", log)[1])
        memory = 2**10 * float(re.search("space:\\s*(\\S*)", log)[1])
    except Exception as e:
        print(e, file=sys.stderr)
        print_command()
        sys.exit(2)

# print(f"file,exit_code,exitsignal,walltime,cputime,memory,terminationreason,options,solver")
print(f"{benchmark},{config},{status},{result},{exit_code},{cputime},{memory}")
