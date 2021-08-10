#!/bin/bash
# we need to load Slurm so we can submit our jobs with sbatch
module load slurm

is_henry=false
# get input (optional) arguments
while getopts H:b:l:u:n: flag
do
    case "${flag}" in
        H) is_henry=${OPTARG};;
        b) base=$OPTARG;;
        l) lower_bound=$OPTARG;;
        u) upper_bound=$OPTARG;;
        n) nstep=$OPTARG;;
    esac
done

# julia print_num_cyc.jl $base $lower_bound $upper_bound $nstep > ./AA_num_cycles.txt

# loop over the xtal names in AA_mofs_to_sim.txt
for xtal in $(cat ./AA_cofs_to_sim.txt)
do
    # define simulation logs output directory
    sim_log_loc=./data/simulation_logs/$xtal

    # define file with cycles or insertion
    n_cycle_loc=./AA_num_cycles.txt

    if $is_henry; 
    then
        sim_log_loc=./data/simulation_logs/henry_calcs/$xtal 
        n_cycle_loc=./AA_ins_per_vol.txt
    fi

    # make output directory if it doesn't exist
    mkdir -p $sim_log_loc

    # loop over the number of cycles
    for n_cycles in $(cat $n_cycle_loc)
    do
        # loop over forcefields
        for ljff in UFF # Dreiding
        do 
        echo "submitting job for $xtal with $n_cycles cycles using $ljff"
        sbatch -J "$xtal-$n_cycles-$ljff" -A simon-grp -p mime5 -n 1 \
            --mail-type=ALL --mail-user=gantzlen \
            -o $sim_log_loc/"$xtal-$n_cycles-$ljff.o" \
            -e $sim_log_loc/"$xtal-$n_cycles-$ljff.e" \
            --export=xtal="$xtal",n_cycles="$n_cycles",ljff="$ljff" gcmc_submit.sh $is_henry
        done
    done
done

