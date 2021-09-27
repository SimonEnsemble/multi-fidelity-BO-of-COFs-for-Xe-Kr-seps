#!/bin/bash
module load slurm

# set default values
is_henry=false
ljff="UFF"

# get input (optional) arguments
while getopts H: flag
do
    case "${flag}" in
        H) is_henry=${OPTARG};;
    esac
done

ins_per_vol=500 # insertions (cycles) per volume

# loop over the xtal names in AA_mofs_to_sim.txt
for xtal in 07012N3_ddec.cif 14040N2_ddec.cif 16290N3_ddec.cif 21111N3_ddec.cif  #$(cat ./AA_cofs_to_sim.txt)
do
    sleep 0.25 # don't overwhelm cluster

    # define simulation logs output directory
    if $is_henry; 
    then
        sim_log_loc=../data/simulation_logs/henry_calcs/$xtal 
    else
        sim_log_loc=../data/simulation_logs/$xtal
    fi

    # make output directory if it doesn't exist
    mkdir -p $sim_log_loc

    echo "submitting job for $xtal with $ins_per_vol cycles/insertions per volume"
    sbatch -J "$xtal-$ins_per_vol-$ljff" -A simon-grp -p mime5 -n 1 \
        --time=7-00:00:00 --mail-type=END,FAIL --mail-user=gantzlen \
        -o $sim_log_loc/"$xtal-$ins_per_vol-$ljff.o" \
        -e $sim_log_loc/"$xtal-$ins_per_vol-$ljff.e" \
        --export=xtal="$xtal",ins_per_vol="$ins_per_vol" simulation_submit.sh $is_henry
done
