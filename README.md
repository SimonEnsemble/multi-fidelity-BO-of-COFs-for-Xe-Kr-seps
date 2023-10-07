# multi-fidelity Bayesian optimization of covalent organic frameworks
:rocket: this repo contains data and code to reproduce the results for:
> N. Gantzler, A. Deshwal, J. Doppa, C. Simon. "Multi-fidelity Bayesian Optimization of Covalent Organic Frameworks for Xenon/Krypton Separations" (2023) [ChemRxiv link](https://chemrxiv.org/engage/chemrxiv/article-details/64970d6a4821a835f355c8b9)

we describe the sequence of steps we took to make our paper reproducible. the output of each step is saved as a file, so you can start at any step.

## required software
required software/packages:
* [Python 3](https://www.python.org/downloads/) version 3.8 or newer (for MFBO)
* [Julia](https://julialang.org/downloads/) version 1.7.3 or newer (for molecular simulations and assembling data)
* [Zeo++](http://www.zeoplusplus.org/download.html) (for computing structural features of the COFs)

## the COF crystal structures
we obtained the dataset of the COF crystal structure files (`.cif`) from [Materials Cloud](https://archive.materialscloud.org/record/2021.100) and stored them in `data/crystals`. see [here](https://github.com/danieleongari/CURATED-COFs) for the COF naming convention.

**the top COF `19440N2`:**
the paper associated with the COF exhibiting the largest high-fidelity Xe/Kr selectivity is:
> "J. Am. Chem. Soc., 2019, 141, 16810-16816", 10.1021/jacs.9b07644, Unveiling Electronic Properties in Metal–Phthalocyanine-Based Pyrazine-Linked Conjugated Two-Dimensional Covalent Organic Frameworks
they report on two novel COFs, one with Zn and one with Cu. the COF with Cu is the 19440N2 (top COF), and the Zn COF is 19441N2.

## molecular simulations of Xe/Kr adsorption in the COFs
we performed mixture grand-canonical Monte Carlo simulations to predict the adsorbtion properties of the COFs by running `htc_screening/sbatch_submit_script.sh` on a HPC cluster which uses SLURM. 
the molecular simulation code in Julia is contained in `htc_screening/multi_fidelity_simulation_script.jl`. this script relies on the `PorousMaterials.jl` package in Julia and runs both low- and high-fidelity simulations.
* the raw simulation output files (`.jld`'s) are in `data/simulations/`
* the simulation data is organized as `.csv` in `targets/{gcmc_simulation.csv, henry_calculations.csv}`

we employed `PorousMaterials.jl` [v0.4.2](https://github.com/SimonEnsemble/PorousMaterials.jl/releases/tag/0.4.2) for the mixture GCMC and Henry coefficient calculations.

## COF descriptors

### structural/geometrical descriptors
we computed structural descriptors using `Zeo++` by running the script `descriptors/submit_zeo_calculations.sh`, which runs locally and computes descriptors for all of the COFs. (if running on a HPC cluster with SLURM, see `descriptors/submit_slurm_job.sh`).
* the raw Zeo++ outputs per-crystal are stored in `descriptors/zeo_outputs/`.
* the raw Zeo++ output for all crystals is compiled in the three files `descriptors/summary_*`.
* the relevant features of the COFs from Zeo++ are assembled in `descriptors/geometric_properties.csv`

### compositional descriptors
we computed the compositional descriptors of the COFs using [`PorousMaterials.jl`](https://github.com/SimonEnsemble/PorousMaterials.jl) (version 0.4.2 or newer) by running `descriptors/cof_features.jl`.
* we stored them in `descriptors/chemical_properties.csv`

### joined structural and compositional features
the COF descriptors are summarized in `descriptors/cof_descriptors.csv`, which joins `descriptors/geometric_properties.csv` and `descriptors/chemical_properties.csv`.

## amalgamating the data for MFBO
we read in and amalgamated the structural and compositional features and low- and high-fidelity simulation results into `targets_and_raw_features.jld2` by running the notebook `Prepare_Data_and_Preliminary_Analysis.ipynb`. this `.jld2` file is what we read into our Jupyter notebooks for Bayes Opt. the data are conveniently stored as a dictionary of arrays. the outputted file is present in `run_BO`.

## Bayes Opt
### initialization
we generate the list of initializing COF IDs using the `run_BO/generate_initializing_cof_ids.ipynb`. this writes a file `search_results/initializing_cof_ids_normalized.pkl` that we read into the Bayes Opt notebooks.

### single- and multi-fidelity Bayes Opt
finally, the two notebooks:
* `run_BO/MultiFidelity_BO.ipynb`
* `run_BO/SingleFidelity_BO.ipynb`
contain the Python code for running Bayes Opt.

the results from each run are stored in `search_results` to be read into our `figs/viz.ipynb` notebook next for analysis.

### visualizations/analysis
we draw plots to summarize the Bayes Opt search results results using `viz.ipynb`. the outputted figures are stored in the `figs` directory. 

## overview of directories
- `data`: contains simulation input and output files.
- `htc_screening`: code to run and analyze the molecular simulations of adsorption in the COFs
- `benchmarking_sims`: contains code and analysis to determine the number of cycles required to reduce statistical error for GCMC simulations and Henry Coefficients below a given threshold. 
- `descriptors`: contains the scritps used to generate the descriptors of the COFs
- `figs`: for creating the figures in our paper
- `search_results`: the BO search results organized by the type of normalization scheme used and subdivided by the type of BO search carried out. also contains files for sets of initializing COFs.
- `targets`: contains the high-fidelity GCMC simulation results and Henry coefficient calculation results for each material in the study as CSV files.
