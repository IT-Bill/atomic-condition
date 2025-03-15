#!/bin/bash

for i in {1..10}; do
    bin/gslSolver.out gsl /atom/data/e/range_out_e${i}.json tempOutput_e${i}.out
done
