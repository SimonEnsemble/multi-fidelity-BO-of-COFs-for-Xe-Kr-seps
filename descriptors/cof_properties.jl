using PorousMaterials, DataFrames, CSV
set_paths(joinpath(pwd(), "../data"))

# read in lines to get COF filenames
filename = joinpath(pwd(), "cof_names.txt")
cof_name_file = open(filename)
cof_names = readlines(cof_name_file)
close(cof_name_file)

# load forcefield
ljff = LJForceField("UFF")

# define groups of elements (useful for tracking and calculating densities)
unique_elements = [:B, :O, :C, :H, :Si, :N, :S, :Ni, :Zn, :Cu, :Co, :F, :P, :Cl, :Br, :V]
commons  = [:B, :O, :C, :H, :Si, :N, :S, :P] # common elements in COFs that we want to track
halogens = [:F, :Cl, :Br]                    # group together the halogens
metals   = [:Zn, :V, :Ni, :Cu, :Co]          # group together metals


grp_name = Dict(:C  => "Carbon",
                :H  => "Hydrogen",
                :O  => "Oxygen",
                :N  => "Nitrogen",
                :Si => "Silicon",
                :S  => "Sulfur",
                :B  => "Boron",
                :P  => "Phosphorus",
                :halo  => "Halogens",
                :metal => "Metals")

# construct dataframe to hold info about COFs
df = DataFrame(crystal_name              = String[], 
               crystal_density       = Float64[], # kg/m³
               density_of_Carbon     = Float64[], # Å⁻³
               density_of_Hydrogen   = Float64[], # Å⁻³
               density_of_Oxygen     = Float64[], # Å⁻³
               density_of_Nitrogen   = Float64[], # Å⁻³
               density_of_Silicon    = Float64[], # Å⁻³
               density_of_Sulfur     = Float64[], # Å⁻³
               density_of_Boron      = Float64[], # Å⁻³
               density_of_Phosphorus = Float64[], # Å⁻³
               density_of_Halogens   = Float64[], # Å⁻³
               density_of_Metals     = Float64[]  # Å⁻³
              )

# function to calculate properties of interest
function crystal_properties(xtal::Crystal)
    # count the total number of each species in the crystal 
    species_count = Dict{Symbol, Int64}()
    for species in xtal.atoms.species
        species in keys(species_count) ? species_count[species] += 1 : species_count[species] = 1
        # track unique atomic species
        species in unique_elements ? continue : (push!(unique_elements, species) ; @warn "$species not previously accounted for in species list")
    end

    # construct a dictionary to strore property values
    properties = Dict{String, Any}()

    # volume of crystal
    volume = xtal.box.Ω

    # initialize counts
    [properties["density_of_" * grp_name[species]] = 0.0 for species in commons]
    num_halogens = 0.0 # number of Halogens 
    num_metals   = 0.0 # number of Metals

    ###
    #  calculate crystal properties
    ###
    properties["crystal_name"] = xtal.name
    properties["crystal_density"] = crystal_density(xtal) # 

    for species in keys(species_count)
        if species in commons
            properties["density_of_" * grp_name[species]] = species_count[species] / volume
        elseif species in halogens
            num_halogens += species_count[species]
        elseif species in  metals
            num_metals += species_count[species]
        end
    end
    properties["density_of_" * grp_name[:halo]]  = num_halogens / volume
    properties["density_of_" * grp_name[:metal]] = num_metals / volume

    return properties
end

# get properties for each material and store in a DataFrame
for cof_name in cof_names
    xtal = Crystal(cof_name; check_neutrality=false);

    # check forcefield coverage
    if !(forcefield_coverage(xtal, ljff))
        @warn "$(xtal.name) is not fully covered under ljff"
    end

    # get properties of interest
    properties = crystal_properties(xtal)

    # now we need to push the properties to the dataframe
    row = [properties[key] for key in names(df)]
    push!(df, row)
end

# now write the Dataframe to a CSV file
CSV.write(joinpath(pwd(), "chemical_properties.csv"), df)
