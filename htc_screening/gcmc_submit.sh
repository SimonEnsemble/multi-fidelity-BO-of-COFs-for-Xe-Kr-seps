#!/bin/bash
date
is_henry=$1
julia adsorption_benchmark_script.jl $xtal $n_cycles $is_henry
