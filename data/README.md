CIF files unpacked from zip file taken from [Materials Cloud](https://archive.materialscloud.org/record/2021.100) on August 24, 2021.
citation:
Daniele Ongari, Aliaksandr V. Yakutovich, Leopold Talirz, Berend Smit, Building a consistent and reproducible database for adsorption evaluation in Covalent-Organic Frameworks, Materials Cloud Archive 2021.100 (2021), doi: 10.24435/materialscloud:z6-jn.

Simulations are run using the same number of burn and sample (production) cycles.

Files and folders: (for clarification see `[PorousMaterials.jl](https://simonensemble.github.io/PorousMaterials.jl/stable/)` docs)
- `crystals`: contains the `.cif` files for each COF
- `forcefields`: contains the forcefield parameters used for framework atoms in the simulations
- `grids`: where (energy or number density) grid files would go. We do not generate any for this project
- `molecules`: contains molecular force field parameter files used to model each adsorbate
- `atomic_properties.csv`: contains the atom labels, masses [amu], radii [Angstrom], ionic radii [Angstrom]
- `vdw_fluid_props.csv`: contains values used by the fluid equation-of-state in smulation