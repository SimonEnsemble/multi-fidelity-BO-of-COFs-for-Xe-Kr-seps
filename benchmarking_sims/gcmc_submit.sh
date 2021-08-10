#!/bin/bash
date
is_henry=$1
julia adsorption_benchmark_script.jl $xtal $n_cycles $ljff $is_henry
