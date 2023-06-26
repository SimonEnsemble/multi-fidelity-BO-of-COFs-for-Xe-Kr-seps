This directory contains the code used to determine how many insertions per volume to use for the Henry calculatoins and the MC cycles per volume to use for the Binary grand-Canonical Monte Carlo (BGCMC) simulations.

- `AA_*.txt`: files called by `submit_isoherm_jobs.sh` to sweep through a range of parameters.
- `adsorption_benchmark_script.jl`: is a `Julia` script which will run either a Henry coefficient calculation or a BGCMC simulation based on commandline inputs.
- `gcmc_submit.sh`: is called by the submission scrit to run `adsorption_benchmark_script.jl` on the HPC cluster.
- `submit_isoherm_jobs.sh`: script to submit jobs on the HPC cluster.
- `Benchmark_analysis.ipynb`: notebook containing code used to analyze the benchmarking simulation results.

**NOTE: The relative error for the GCMC simulation for both materials being benchmarked is below 0.05 when we use 500 cycles per volume. The relative error for the Henry coefficient is well below 0.05 with 500 insertions per volume. Therefore, we will use the GCMC as the limiting statistic and run the HTC Screening using 500 insertions (cycles) per volume.**