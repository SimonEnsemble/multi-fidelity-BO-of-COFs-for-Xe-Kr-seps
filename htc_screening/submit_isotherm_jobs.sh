#!/bin/bash
module load slurm

# set default values
is_henry=false
ljff="UFF"

# get input (optional) arguments
while getopts H:g:b:l:u:n: flag
do
    case "${flag}" in
        H) is_henry=${OPTARG};;
    esac
done

if $is_henry
then
    number_of_cycles = 300 
else
    number_of_cycles = 100000
fi


# loop over the xtal names in AA_mofs_to_sim.txt
for xtal in $(cat ./AA_cofs_to_sim.txt)
do
    # define simulation logs output directory
    if $is_henry; 
    then
        sim_log_loc=../data/simulation_logs/henry_calcs/$xtal 
    else
        sim_log_loc=../data/simulation_logs/$xtal
    fi

    # make output directory if it doesn't exist
    mkdir -p $sim_log_loc

    echo "submitting job for $xtal with $n_cycles cycles"
    sbatch -J "$xtal-$n_cycles-$ljff" -A simon-grp -p mime5 -n 1 \
        --mail-type=ALL --mail-user=gantzlen \
        -o $sim_log_loc/"$xtal-$n_cycles-$ljff.o" \
        -e $sim_log_loc/"$xtal-$n_cycles-$ljff.e" \
        --export=xtal="$xtal",n_cycles="$number_of_cycles" gcmc_submit.sh $is_henry
done
