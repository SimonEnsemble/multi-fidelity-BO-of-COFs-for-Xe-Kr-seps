#!/bin/bash
# we need to load Slurm so we can submit our jobs with sbatch
module load slurm

# set default values
is_henry=false
gas=Xe
number_of_cycles=500

# get input (optional) arguments
while getopts H: flag
do
    case "${flag}" in
        H) is_henry=${OPTARG};;
    esac
done


# loop over the xtal names in AA_mofs_to_sim.txt
for xtal in $(cat ./AA_cofs_to_sim.txt)
do
    # define simulation logs output directory
    sim_log_loc=../data/simulation_logs/$xtal

    # define file with cycles or insertion
    n_cycle_loc=./AA_ins_per_vol.txt #./AA_num_cycles.txt

    if $is_henry; 
    then
        sim_log_loc=../data/simulation_logs/henry_calcs/$xtal 
        n_cycle_loc=./AA_ins_per_vol.txt
    fi

    # make output directory if it doesn't exist
    mkdir -p $sim_log_loc

    # loop over the number of cycles
    for n_cycles in $(cat $n_cycle_loc) #$number_of_cycles 
    do
        # don't want to overwhelm system
        sleep 0.25
 
        # loop over forcefields
        for ljff in UFF # Dreiding
        do 
        echo "submitting job $xtal with $n_cycles cycles"
        sbatch -J "$xtal-$n_cycles-$ljff" -A simon-grp -p mime5 -n 1 \
            --mail-type=END,FAIL --mail-user=gantzlen \
            -o $sim_log_loc/"$xtal-$n_cycles-$ljff.o" \
            -e $sim_log_loc/"$xtal-$n_cycles-$ljff.e" \
            --export=xtal="$xtal",n_cycles="$n_cycles" gcmc_submit.sh $is_henry
        done
    done
done

