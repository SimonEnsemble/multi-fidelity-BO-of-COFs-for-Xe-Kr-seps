#using Xtals
using PorousMaterials

# read in lines to get COF filenames
filename = joinpath(pwd(), "cof_names.txt")
cof_name_file = open(filename)
cof_names = readlines(cof_name_file)
close(cof_name_file)

# load forcefield
ljff = LJForceField("UFF")

unique_elements = Symbol[]
for cof_name in cof_names
    tmp_xtal = Crystal(cof_name; check_overlap=false, check_neutrality=false);
    for species in unique(tmp_xtal.atoms.species)
        species in unique_elements ? continue : push!(unique_elements, species)
    end

    if :Zn in keys(chemical_formula(tmp_xtal)) 
        println(tmp_xtal.name)
    end

    # check forcefield coverage
    if !(forcefield_coverage(tmp_xtal, ljff))
        @warn "$(tmp_xtal.name) is not fully covered under ljff"
    end
end

println(unique_elements)
