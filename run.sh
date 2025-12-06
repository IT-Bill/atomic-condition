#!/bin/bash

for i in {0..9}; do
    bin/gslSolver.out gsl /atom/data/half/range_out_${i}.json tempOutput_${i}.out
done
