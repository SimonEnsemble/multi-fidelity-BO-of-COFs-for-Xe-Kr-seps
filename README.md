# multi-fidelity Bayesian optimization of covalent organic frameworks
this repo contains data and code to reproduce the results for:
> N. Gantzler, A. Deshwal, J. Doppa, C. Simon. "Multi-fidelity Bayesian Optimization of Covalent Organic Frameworks for Xenon/Krypton Separations"

## required software
required software/packages:
* [Python 3](https://www.python.org/downloads/) version 3.8 or newer (for MFBO)
* [Julia](https://julialang.org/downloads/) version 1.7.3 or newer (for molecular simulations and assembling data)
* [Zeo++](http://www.zeoplusplus.org/download.html) (for computing structural features of the COFs)

## the COF crystal structures
we obtained the dataset of the COF crystal structure files (`.cif`) from [Materials Cloud](https://archive.materialscloud.org/record/2021.100) and stored them in `data/crystals`. see [here](https://github.com/danieleongari/CURATED-COFs) for the COF naming convention.

### the top COF `19440N2`
the paper associated with the COF exhibiting the largest high-fidelity Xe/Kr selectivity is:
> "J. Am. Chem. Soc., 2019, 141, 16810-16816", 10.1021/jacs.9b07644, Unveiling Electronic Properties in Metal–Phthalocyanine-Based Pyrazine-Linked Conjugated Two-Dimensional Covalent Organic Frameworks
they report on two novel COFs, one with Zn and one with Cu. the COF with Cu is the 19440N2 (top COF), and the Zn COF is 19441N2.

## molecular simulations of Xe/Kr adsorption in the COFs
we performed mixture grand-canonical Monte Carlo simulations to predict the adsorbtion properties of the COFs by running `htc_screening/sbatch_submit_script.sh` on a HPC cluster which uses SLURM. 
the molecular simulation code in Julia is contained in `htc_screening/multi_fidelity_simulation_script.jl`. this script relies on the `PorousMaterials.jl` package in Julia and runs both low- and high-fidelity simulations.
* the raw simulation output files (`.jld`'s) are in `data/simulations/`

## COF descriptors
### structural/geometrical descriptors
we computed structural descriptors using `Zeo++` by running the script `descriptors/submit_zeo_calculations.sh`, which runs locally and computes descriptors for all of the COFs. (if running on a HPC cluster with SLURM, see `descriptors/submit_slurm_job.sh`).
* the raw Zeo++ outputs per-crystal are stored in `descriptors/zeo_outputs/`.
* the raw Zeo++ output for all crystals is compiled in the three files `descriptors/summary_*`.
* the relevant features of the COFs from Zeo++ are assembled in `descriptors/geometric_properties.csv`

### compositional descriptors
we computed the compositional descriptors of the COFs using [`PorousMaterials.jl`](https://github.com/SimonEnsemble/PorousMaterials.jl) (version 0.4.2 or newer) by running `descriptors/cof_features.jl`.
* we stored them in `descriptors/chemical_properties.csv`


## amalgamating the data for MFBO
5. Prepare Data (feature vectors and targets) for use in the BO search by running the `Prepare_Data_and_Preliminary_Analysis.ipynb` (soon `new_prepare_data.jl`) 
    The results are stored in `targets_and_*_features.jld2` where '*' is the normalization scheme.

## Bayes Opt
6. Generate the list of initializing COF IDs using the `run_BO/generate_initializing_cof_ids.ipynb`.
7. Run Bayesian Optimization (BO) search notebooks. The results are stored in `search_results` directory
    - `MultiFidelity_BO.ipynb`
    - `SingleFidelity_BO.ipynb`

## visualizations
8. Generate plots from search results using `viz.ipynb`. Figures are stored in the `figs` directory. 


## Files, Folders, and their contents:
- `benchmarking_sims`: contains code and analysis to determine the number of cycles required to reduce statistical error for GCMC simulations and Henry Coefficients below a given threshold. 
- `data`: contains simulation input and output files.
- `descriptors`: contains the scritps used to generate the data used in training the Gaussian Process.
- `figs`: contains plots, and project files needed to generate the figures in the associated text.
- `htc_screening`: contains code to run and analyze the high-throughput comuptational screening of the COFs in `./data/crystals`.
- `search_results`: the BO search results organized by the type of normalization scheme used and subdivided by the type of BO search carried out. Also contains files for sets of initializing COFs under each scheme.

- `targets`: contains the high-fidelity GCMC simulation results and Henry coefficient calculation results for each material in the study as CSV files.


notebooks and datafiles:
- `Prepare_data_and_Preliminary_analysis`: prepares data to be used for BO and looks at some correlations between data
- `generate_initializing_cof_ids`: Generate the lists of COFs used to initialize the GP models for the BO searches
- `MultiFidelity_BO`: contains the code to run the multi-fidelity Bayesian Optimization search
- `SingleFidelity_BO`: contains the code to run the single-fidelity Bayesian Optimization search and random search
- `Train_GP_on_All_COFs`: testing whether it is possible for a GP to learn the correlation between high-fidelity and low-fidelity molecular simulations given a set of features and examines the accuracy. N.b. this notebook used ScikitLearn, and probably should get moved into the benchmark directory?
- `viz`: contains potting code for figures in the text.


