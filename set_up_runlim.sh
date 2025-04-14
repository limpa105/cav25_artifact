#!/bin/bash
set -e

wget https://fmv.jku.at/runlim/runlim-1.10.tar.gz
tar xf runlim-1.10.tar.gz
cd runlim-1.10
./configure.sh
make
cp runlim ../



