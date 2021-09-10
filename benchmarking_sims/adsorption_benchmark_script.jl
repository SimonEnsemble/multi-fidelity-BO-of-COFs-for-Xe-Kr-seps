using PorousMaterials
# set file paths
# set_paths(joinpath(pwd(), "../data"))

###
#  Read command line arguments: name of - crystal structure, adsorbate, and forcefield
###
if length(ARGS) != 3
    error("pass the crystal structure name as a command line argument followed by the number of cycles then the forcefield,
 	such as: julia cof_isotherm_sim.jl COF-102.cif 5000  true")
end

crystal  = ARGS[1]
num_str  = ARGS[2]
henry    = ARGS[3]

println("running mol sim on", crystal, " with ", num_str, " cycles")

is_henry = parse(Bool, henry)
n_cycles = parse(Int64, num_str)


###
#  Set Simulation Parameters and keyword arguments
###
mol_fractions = [0.8, 0.2] # [Kr, Xe]
total_pressure = 1.0       # bar
partial_pressures = total_pressure .* mol_fractions

sim_params = Dict("xtal"        => Crystal(crystal),
                  "molecules"   => [Molecule("Kr"), Molecule("Xe")],
                  "temperature" => 298.0,
                  "pressures"   => partial_pressures,
                  "ljff"        => LJForceField("UFF")
                 )

strip_numbers_from_atom_labels!(sim_params["xtal"])

kwargs = Dict(:n_cycles_per_volume => n_cycles)

###
#  Run simulation
###
if is_henry
    for gas in sim_params["molecules"]
        results = henry_coefficient(sim_params["xtal"], 
                                    gas, 
                                    sim_params["temperature"],
                                    sim_params["ljff"];
                                    insertions_per_volume=n_cycles
                                   )
    end
else
    results = μVT_sim(sim_params["xtal"],
                      sim_params["molecules"],
                      sim_params["temperature"],
                      sim_params["pressures"],
                      sim_params["ljff"];
                      kwargs...
                     )
end
