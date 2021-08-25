# print the number of cycles we want to use in the simulation
n_cycles = Int.(floor.(10 .^ range(log10(25), stop=3, length=100)))
for n in n_cycles
    println(n)
end
