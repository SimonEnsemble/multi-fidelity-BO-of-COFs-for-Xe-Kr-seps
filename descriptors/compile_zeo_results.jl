using DataFrames, CSV

# read in lines to get COF filenames
filename = joinpath(pwd(), "cof_names.txt")
cof_name_file = open(filename)
cof_names = readlines(cof_name_file)
close(cof_name_file)

# define DataFrame to store desired values
df = DataFrame(crystal_name       = String[],
               pore_diameter_Å    = Float64[],
               void_fraction      = Float64[],
               surface_area_m²g⁻¹ = Float64[]
              )

# loop over COFs
for cof_name in cof_names
    # initialize variables
    sphere_diameter = ""
    v_fraction      = ""
    surface_area    = ""

    ###
    # read in data 
    ###
    sphere_dia_filename = joinpath(pwd(), "zeo_outputs", cof_name * ".res")
    void_fxn_filename   = joinpath(pwd(), "zeo_outputs", cof_name * ".vol")
    surf_area_filename  = joinpath(pwd(), "zeo_outputs", cof_name * ".sa")

    sphere_dia_file = open(sphere_dia_filename)
    void_fxn_file   = open(void_fxn_filename)
    surf_area_file  = open(surf_area_filename)

    sphere_diameter_lines = readlines(sphere_dia_file)
    void_fraction_lines   = readlines(void_fxn_file)
    surface_area_lines    = readlines(surf_area_file)

    close(sphere_dia_file)
    close(void_fxn_file)
    close(surf_area_file)

    ###
    #  make sure we have the correct files
    ###
    @assert occursin(cof_name, sphere_diameter_lines[1]) "read in the wrong .res file for $cof_name"
    @assert occursin(cof_name, void_fraction_lines[1])   "read in the wrong .vol file for $cof_name"
    @assert occursin(cof_name, surface_area_lines[1])    "read in the wrong .sa file for $cof_name"

    ###
    #  get desired values:
    #  1. split line by white space characters
    #  2. get index of data we want (if we don't know the index a priori)
    #     see http://www.zeoplusplus.org/examples.html for output file formatting
    #  3. write values to DataFrame
    ###
    sd_splitline = split(sphere_diameter_lines[1], " ")  # single line file
    vf_splitline = split(void_fraction_lines[1], " ")    # only need the first line
    sa_splitline = split(surface_area_lines[1], " ")     # only need the first line

#    println("\n sd_splitline \n", sd_splitline)
#    println("\n vf_splitline \n", vf_splitline)
#    println("\n sa_splitline \n", sa_splitline)

    # largest included sphere diameter
    sphere_diameter = sd_splitline[5] 

    # He void fraction
    for (ind, word) in enumerate(vf_splitline)
        word == "AV_Volume_fraction:" ? v_fraction = vf_splitline[ind + 1] : continue
    end

    # accessible surface area (to He probe) per gram of material
    for (ind, word) in enumerate(sa_splitline)
        word == "ASA_m^2/g:" ? surface_area = sa_splitline[ind + 1] : continue
    end

    # data is read in as strings, so we have to parse(Float64, data) when passing it to DataFrame
    row = [cof_name, parse(Float64, sphere_diameter), parse(Float64, v_fraction), parse(Float64, surface_area)]
    push!(df, row)
end

CSV.write(joinpath(pwd(), "geometric_properties.csv"), df)
