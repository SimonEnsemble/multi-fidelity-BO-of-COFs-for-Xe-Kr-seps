# computing structural descriptors of the COFs
This directory contains the scripts necessary to generate the chemical and geometric descriptors of the COFs.
- `chemical_properties.csv`: file containing chemical property descriptors of interest for each material
- `cof_descriptors.csv`: file containing each COF's name and associated descriptor values
- `cof_features.jl`: A Julia Pluto notebook which uses `PorousMaterials.jl` to determine chemical property descritors for each material and write them to `chemical_properties.csv`
- `cof_names.txt`: file containing the names of every material (COF) we want to study
- `compile_zeo_results.jl`: A Julia Pluto notebook which parses `Zeo++` data and writes desired geometric properties to `geometric_properties.csv` for each material
- `geometric_properties.csv`: file containing geometric property descriptors of interest for each material
- `submit_slurm_job.sh`: bash script used to run batch jobs on the HPC cluster
- `submit_zeo_calculations.sh`: bash script used to run `Zeo++` calculations 
- `summary_*.txt`: files containing a summary of specific properties (indicated in filename) from the `Zeo++` output for each material
- `zeo_outputs`: raw data files output by `Zeo++` calculations.
