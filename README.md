## Where to start:

required software/packages:
```
[Python 3](https://www.python.org/downloads/) version 3.8 or newer
[Julia](https://julialang.org/downloads/) version 1.9 or newer
[Zeo++](http://www.zeoplusplus.org/download.html)
[iRASPA](https://iraspa.org/iraspa/)
```

1. A dataset of the COFs crystal structure files (`.cif`) are obtained from [Materials Cloud](https://archive.materialscloud.org/record/2021.100) and stored in the `data/crystals` (already done).
2. Get geometric descriptors using `Zeo++` by running the `descriptors/submit_zeo_calculations.sh` (runs locally)
    the output will be compiled into `descriptors/geometric_properties.csv`
    - If you are running it on a HPC cluster which uses SLURM, as we did, see the submission script 
        `descriptors/submit_slurm_job.sh`
    - The raw data is stored in the `zeo_outputs/` sub directory.
3. Get composition descriptors using `PorousMaterials.jl` (`gcmc_mixtures` branch in developement) by running `descriptors/cof_features.jl`and store them in `descriptors/geometric_properties.csv`
4. Run HTC Screening of COFs i.e. perform mixture grand-canonical Monte Carlo simulations to obtain adsorbtion properties by running `htc_screening/sbatch_submit_script.sh` on a HPC cluster which uses SLURM.
5. Prepare Data (feature vectors and targets) for use in the BO search by running the `Prepare_Data_and_Preliminary_Analysis.ipynb` (soon `new_prepare_data.jl`) 
    The results are stored in `targets_and_*_features.jld2` where '*' is the normalization scheme.
6. Generate list of initializing COFs with `generate_initializing_cof_ids.ipynb`
7. Run Bayesian Optimization (BO) search notebooks. The results are stored in `run_BO` directory
    - `MultiFidelity_BO.ipynb`
    - `SingleFidelity_BO.ipynb`
8. Generate plots from search results using `viz.ipynb`. Figures are stored in the `figs` directory. 



## Files, Folders, and their contents:
- `benchmarking_sims`: contains code and analysis to determine # cycles vs error for GCMC simulations and Henry Coefficients.
- `data`: contains simulation input and output files
- `descriptors`: contains the scritps used to generate the data used in training the Gaussian Process.
- `figs`: contains plots, and project files needed to generate the figures in the associated text.
- `htc_screening`: contains code to run and analyze the high-throughput comuptational screening of the COFs in `./data/crystals`.
- `search_results`: the BO search results organized by the type of normalization scheme used and subdivided by the type of BO search carried out. Also contains files for sets of initializing COFs under each scheme.


notebooks and datafiles:
- `Prepare_data_and_Preliminary_analysis`: prepares data to be used for BO and looks at some correlations between data
- `generate_initializing_cof_ids`: Generate the lists of COFs used to initialize the GP models for the BO searches
- `MultiFidelity_BO`: contains the code to run the multi-fidelity Bayesian Optimization search
- `SingleFidelity_BO`: contains the code to run the single-fidelity Bayesian Optimization search and random search
- `Train_GP_on_All_COFs`: testing whether it is possible for a GP to learn the correlation between high-fidelity and low-fidelity molecular simulations given a set of features and examines the accuracy. N.b. this notebook used ScikitLearn, and probably should get moved into the benchmark directory?
- `viz`: contains potting code for figures in the text.



The paper associated with the top performing COF is:
p1944,"J. Am. Chem. Soc., 2019, 141, 16810-16816",10.1021/jacs.9b07644,Unveiling Electronic Properties in Metal–Phthalocyanine-Based Pyrazine-Linked Conjugated Two-Dimensional Covalent Organic Frameworks
In the paper they report on two novel COFs on with Zn and one with Cu. The COF with Cu is the 19440N2 (top COF) and the Zn COF is 19441N2.
See [here](https://github.com/danieleongari/CURATED-COFs) for the labeling convention.

