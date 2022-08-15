#!/bin/bash
module load slurm

echo "Running_Zeo_Calcs" 
sbatch -J "Running_Zeo_Calcs" -A simon-grp -p mime5 -n 1 \ 
    --time=1-00:00:00 --mail-type=END,FAIL --mail-user=gantzlen \
    -o "output.o" -e "error.e" \
    ./submit_zeo_calculations.sh

