Notebooks:
1. `generate_initializing_cof_ids.ipynb`: This is a jupyter notebook containing code to generate the sets of COF used to initialize the models in the `*_BO` notebooks. 
2. `MultiFidelity_BO.ipynb`: This is a jupyter notebook containing the code used to perform the Multi-fidelity Bayesian Optimization searches.
    - this notebook contains a flag to run the multi-fidelity ablation study for testing the model dependence on the features.
3. `SingleFidelity_BO.ipynb`: This is a jupyter notebook containing the code used to perform the Single-fidelity Bayesian Optimization searches and the single-/high-fidelity random search. 
4. `ordinary_ML.ipynb`: This notebook contains code to test the MFBO feature dependence.

Files:
- `targets_and_normalized_features.jld2`: This file contains the selectivities (targets) and the min-max normalized COF features used by the surrogate models in the notebooks.
- `targets_and_raw_features.jld2`: This file contains the selectivities (targets) and the raw features used in the MFBO notebook to test whethere the data is being loaded correctly. 