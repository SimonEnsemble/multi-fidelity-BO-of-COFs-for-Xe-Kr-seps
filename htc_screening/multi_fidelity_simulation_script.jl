using PorousMaterials

###
#  Read command line arguments: name of crystal structure, number of MC cycles, and Henry flag
###
if length(ARGS) != 3
    error("run with command line arguments, e.g.:
        julia multi_fidelity_simulation_script.jl 05000N2_ddec.cif 5000 true")
end
xtal_name                = ARGS[1]                # name of crystal structure
nb_insertions_per_volume = parse(Int64, ARGS[2])  # number of insertions per volume
is_henry                 = parse(Bool, ARGS[3])   # flag for Henry calculation

###
#  set file paths
###
set_paths(joinpath(pwd(), "../data"))

###
#  Set Simulation Parameters and keyword arguments
###
xtal              = Crystal(xtal_name; check_neutrality=false)
adsorbates        = [Molecule("Kr"), Molecule("Xe")]
temperature       = 298.0 # K
ljff              = LJForceField("UFF")
# for μVT only
mol_fractions     = [0.8, 0.2] # [Kr, Xe]
total_pressure    = 1.0       # bar
partial_pressures = total_pressure * mol_fractions

###
#  Run simulation(s)
###
if is_henry
    for gas in adsorbates
        results = henry_coefficient(xtal, gas, temperature, ljff; insertions_per_volume=nb_insertions_per_volume)
    end
else
    # additional keyword arguments
    kwargs = Dict(:n_burn_cycles   => nb_insertions_per_volume, 
                  :n_sample_cycles => nb_insertions_per_volume 
                 )
    results = μVT_sim(xtal, adsorbates, temperature, partial_pressures, ljff; kwargs...)
end
