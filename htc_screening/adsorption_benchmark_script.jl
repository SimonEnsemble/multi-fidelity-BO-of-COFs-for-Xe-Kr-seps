using PorousMaterials
# set file paths
set_paths(joinpath(pwd(), "../data"))

###
#  Read command line arguments: name of crystal structure, number of MC cycles, and Henry flag
###
if length(ARGS) != 3
    error("pass the crystal structure name as a command line argument followed by the number of cycles then the forcefield,
    such as: julia cof_isotherm_sim.jl COF-102.cif 5000 true")
end
crystal  = ARGS[1] # crystal name
num_str  = ARGS[2] # number of MC cycles or insertions per volume
henry    = ARGS[3] # flag for Henry calculation

is_henry = parse(Bool, henry)
n_cycles = parse(Int64, num_str)


###
#  Set Simulation Parameters and keyword arguments
###
xtal = Crystal(crystal; check_overlap=false, check_neutrality=false);
adsorbates = [Molecule("Kr"), Molecule("Xe")]
mol_fractions = [0.8, 0.2] # [Kr, Xe]
total_pressure = 1.0       # bar
partial_pressures = total_pressure .* mol_fractions
temperature = 298.0 # K
ljff = LJForceField("UFF")

# additional keyword arguments
kwargs = Dict(:n_burn_cycles   => n_cycles, 
              :n_sample_cycles => n_cycles
             )

###
#  Run simulation
###
if is_henry
    for gas in adsorbates
        results = henry_coefficient(xtal, gas, temperature, ljff; insertions_per_volume=n_cycles)
    end
else
    results = μVT_sim(xtal, adsorbates, temperature, partial_pressures, ljff; kwargs...)
end
