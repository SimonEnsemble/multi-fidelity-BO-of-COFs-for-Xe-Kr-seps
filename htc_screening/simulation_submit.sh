#!/bin/bash
date
is_henry=$1
julia multi_fidelity_simulation_script.jl $xtal $ins_per_vol $is_henry
