Files, Folders, and their contents:
- `benchmarking_sims`: contains code and analysis to determine # cycles vs error for GCMC simulations and Henry Coefficients.
- `data`: contains simulation input and output files
- `descriptors`: contains the scritps used to generate the data used in training the Gaussian Process.
- `figs`: contains plots, and project files needed to generate the figures in the associated text.
- `htc_screening`: contains code to run and analyze the high-throughput comuptational screening of the COFs in `./data/crystals`.
- `search_results`: the BO search results organized by the type of normalization scheme used and subdivided by the type of BO search carried out. Also contains files for sets of initializing COFs under each scheme.

TODO: 
- organize/move notebooks and datafiles out of the main directory and into a more logical location

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

