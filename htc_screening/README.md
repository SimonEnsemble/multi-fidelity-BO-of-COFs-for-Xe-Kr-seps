This directory contains files nessecary for running the GCMC (high fidelity) and Henry (low fidelity) simulations on the HPC.
- `AA_cof_to_sim.txt`: file containing the list of materials to run simulations on
- `multi_fidelity_simulation_script.jl`: scripts that uses `PorousMaterials.jl` to run simulations
- `sbatch_submit_script.sh`: bash script that submits jobs to Slurm
    note: must pass `-H true` flag in order to run Henry calculations
- `simulation_submit.sh`: bash script used by Slurm to exicute simulation script

Notes:
1. Simulation output `.jld2` files located in `../data/simulations` 
2. `--mem=4G` used on `14040N2_ddec.cif` to resolve `OUT_OF_MEMORY` error message from SLURM.
