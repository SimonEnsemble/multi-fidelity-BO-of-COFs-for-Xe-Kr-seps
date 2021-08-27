This directory cnotains the scripts nessecary to generate the chemical and geometric descriptors used to train a Gaussian Process.
- `chemical_properties.csv`: file containing chemical property descriptors of interest for each material
- `cof_names.txt`: file containing the names of every material (COF) we want to study
- `cof_properties.jl`: uses `PorousMaterials.jl` to determine chemical property descritors for each material and write them to `chemical_properties.csv`
- `compile_zeo_results.jl`: parses `Zeo++` data and writes desired geometric properties to `geometric_properties.csv` for each material
- `geometric_properties.csv`: file containing geometric property descriptors of interest for each material
- `submit_zeo_calculations.sh`: bash script used to run `Zeo++` calculations 
- `summary_*.txt`: files containing a summary of specific properties (indicated in filename) from the `Zeo++` output for each material

