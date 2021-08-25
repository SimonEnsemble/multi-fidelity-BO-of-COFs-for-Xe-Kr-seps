#using Xtals
using PorousMaterials, DataFrames, CSV
set_paths(joinpath(pwd(), "../data"))

# read in lines to get COF filenames
filename = joinpath(pwd(), "cof_names.txt")
cof_name_file = open(filename)
cof_names = readlines(cof_name_file)
close(cof_name_file)

# load forcefield
ljff = LJForceField("UFF")

# unique_elements = Symbol[]
unique_elements = [:B, :O, :C, :H, :Si, :N, :S, :Ni, :Zn, :Cu, :Co, :F, :P, :Cl, :Br, :V]

grp_name = Dict(:C => "Carbon", 
                :H => "Hydrogen",
                :O => "Oxygen",
                :N => "Nitrogen",
                :Si => "Silicon",
                :S => "Sulfur",
                :halo  => "Halogens",
                :metal => "Metals")

# construct dataframe to hold info about COFs
df = DataFrame(crystal_name        = String[], 
               crystal_density     = Float64[],
               density_of_Carbon   = Float64[], 
               density_of_Hydrogen = Float64[], 
               density_of_Oxygen   = Float64[], 
               density_of_Nitrogen = Float64[], 
               density_of_Silicon  = Float64[], 
               density_of_Sulfur   = Float64[],
               density_of_Halogens = Float64[], 
               density_of_Metals   = Float64[] 
              )

# function to calculate properties of interest
function crystal_properties(xtal::Crystal)
    # construct a dictionary to strore property values
    properties = Dict{String, Any}()

    # dictionary containing chemical formula for crystal
    chem_formula = chemical_formula(xtal)

    # volume of crystal
    volume = xtal.box.Ω

    # initialize counts
    [properties["density_of_" * grp_name[species]] = 0.0 for species in [:C, :H, :O, :N, :Si, :S]]
    num_halogens = 0.0 # number of Halogens 
    num_metals   = 0.0 # number of Metals

    ###
    #  calculate crystal properties
    ###
    properties["crystal_name"] = xtal.name
    properties["crystal_density"] = crystal_density(xtal) # kg/m²

    for species in keys(chem_formula)
        if species in [:C, :H, :O, :N, :Si, :S]
            properties["density_of_" * grp_name[species]] = chem_formula[species] / volume
        elseif species in [:F, :Cl, :Br]
            num_halogens += chem_formula[species]
        elseif species in  [:Zn, :V, :Ni, :Cu, :Co]
            num_metals += chem_formula[species]
        end
    end
    properties["density_of_" * grp_name[:halo]]  = num_halogens / volume
    properties["density_of_" * grp_name[:metal]] = num_metals / volume

    return properties
end


for cof_name in cof_names
    xtal = Crystal(cof_name; check_neutrality=false);

    for species in unique(xtal.atoms.species)
        species in unique_elements ? continue : push!(unique_elements, species)
    end

    # check forcefield coverage
    if !(forcefield_coverage(xtal, ljff))
        @warn "$(xtal.name) is not fully covered under ljff"
    end

    # get properties of interest
    properties = crystal_properties(xtal)

    # now we need to push the properties to the dataframe
    row = [properties[key] for key in names(df)]
    push!(df, row)

    # now write the Dataframe to a CSV file
    CSV.write(joinpath(pwd(), "geometric_properties.csv"), df)
end
