### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 358c0f22-977a-4388-9a90-fdccde3d2828
begin
	using JLD2
	using PyPlot
	using StatsBase # Statistics
	using Distributions
	using PyCall
	using ScikitLearn # machine learning package
	
	# config plot settings
	PyPlot.matplotlib.style.use("ggplot")
	rcParams = PyPlot.PyDict(PyPlot.matplotlib."rcParams")
	rcParams["font.size"] = 14;
end

# ╔═╡ a9850e5c-a28f-49f7-8fb6-d0358b440996
using PlutoUI

# ╔═╡ 546656d5-48de-41fc-91f7-1da6a2e1fbc2
md"**I need to figure out how (on which cmputer) I am going to give this presentation**"

# ╔═╡ 498463b9-f73f-40ba-aa2f-eebd545d8dc9
md"""
# MOGP and MFBO for Xe/Kr Separations

PROMPT --
	Give a lecture on (i) multi-output GPs with a simple example and explaining how they work/how they take into account correlation between the two outputs and (ii) multi-fidelity BO where you explain the idea behind the EI acquisition function with multi-fidelity, and then implement this with your Xe/Kr work?
"""

# ╔═╡ 126e90be-757e-4c76-a0a1-4d1bdc68b089
md"""
## Part 1: Multi-ouput Gaussian Processes (MOGP)
### 1.1 Review of GP
	(a) What is a GP (broadly)?
"""

# ╔═╡ 15f17cfe-ed5e-48e0-83e1-79382a85cb08
md"""
- A Gaussian process is a probabilistic method that gives a confidence interval for the predicted function

- "For a given set of training points, there are, potentially, infinitely many functions that fit the data. Gaussian Processes offer an elegant soluton to this problem by assigning a probability to each of these functions"

**Ex:** The first function that attemps to fit the data is *less likely* to be that actual data-generating function than the second fit. 

note -- would it be a good idea to put error bars on the data and show how those error are normally distributed? Also, do the probabilities of each fitting function have their own distribution (i.e. error bars normally distributed within the probability function)?
"""

# ╔═╡ 15066ae2-ea35-4353-ad03-fad595019c34
begin 
	# generate data and fit functions
	x1 = range(-1.0, stop=1.0, length=25)    # domain of data
	y1 = x1 .* x1 .+ 1.0                     # fit 1: quadratic 
	y2 = 0.5 * (exp.(-1 * x1) .+ exp.(x1))   # fit 2: hyperbolic cosine
	noise = rand(Normal(0, 0.1), length(x1)) # Normally distributed random noise 
	max_noise = maximum(noise)
	# generate figure
	fig, axs = subplots(1, 2, figsize=(10,5))
	# plot data
	axs[1].scatter(x1, y2 .+ noise, label="data", color="C0")
	# plot fit 1
	axs[1].fill_between(x1, y1.-max_noise, y1.+max_noise, 
						color="C1", alpha=0.15, hatch="-")
	axs[1].plot(x1, y1, label="fit 1", color="C1")
	
	# plot fit 2
	axs[1].fill_between(x1, y2.-max_noise, y2.+max_noise, 
						color="C2", alpha=0.15, hatch="/")
	axs[1].plot(x1, y2, label="fit 2", color="C2")
	axs[1].set_ylim(ymin=0.0)
	axs[1].set_xlim([-1.03, 1.03])
	axs[1].set_xlabel("x")
	axs[1].set_ylabel("y")
	axs[1].legend()
	# generate probability distribution for fit functions
	μ = 0.5; σ = 0.2
	x2 = range(0.0, stop=1.0, length=100)
	y3 = 0.5 .* (1 ./ (σ .* sqrt(2*π))) .* exp.(-0.5 .* ((x2.-μ)./σ).^2)
	axs[2].plot(x2, y3)
	axs[2].fill_between(x2, zeros(length(x2)), y3, color="C4", alpha=0.3, hatch="//")
	axs[2].scatter([0.8], [0.28], label="fit 1", 
				   facecolor="C1", edgecolor="k", linewidth=0.75, zorder=3)
	axs[2].scatter([0.4], [0.85], label="fit 2", 
				   facecolor="C2", edgecolor="k", linewidth=0.75, zorder=3)
	axs[2].set_ylim(ymin=0.0)
	axs[2].set_xlim([0.0, 1.0])
	axs[2].set_ylabel("probability")
	axs[2].set_xlabel("function space")
	axs[2].set_xticks(range(0.0, stop=1.0, length=5))
	axs[2].set_xticklabels(["", "", L"μ_{f}", "", ""])
	axs[2].legend()
	gcf()
end

# ╔═╡ d5e92de2-4bd4-4882-80bb-6a34e0b14258
md"The mean ($μ_{f}$) of the probability distribution represents the *most probable* characterization of the data."

# ╔═╡ e920b1b8-dd14-4dd8-b4e7-250074602c45


# ╔═╡ 73e98915-09ff-4bef-b474-d28f2a43bee7
md"""
	(b) Properties of Multi-varriate Gaussians
"""

# ╔═╡ 60a81b29-678d-46fb-adf4-e67a6f11b7c5
md"""
Each random variable is distributed normally and their joint distribution is also Gaussian. Here, random variables correspnd to the attributes of our feature vectors which represent the materials.

Material Features:

Chemical Composition | Structural (geometric)
:------ | :--------
Density of Hydrogen [m⁻³] | Pore diameter [Å]
Density of Carbon [m⁻³] | Void fraction
Density of Oxygen [m⁻³] | Surface area [m² g⁻¹]
Density of Nitrogen [m⁻³] | Crystal mass density [kg m⁻³]
Density of Silicon [m⁻³] | 
Density of Sulfur [m⁻³] | 
Density of Boron [m⁻³] | 
Density of Phosphorus [m⁻³] | 
Density of Halogens [m⁻³] | 
Density of Metals [m⁻³] | 

"""

# ╔═╡ 2634b302-4b64-442f-b2bf-61b8d2bfa93e
L"""
	X = \begin{bmatrix}
		   x_{1} \\
		   x_{2} \\
		   \vdots \\
		   x_{n}
		 \end{bmatrix} ∼ \mathcal{N}(μ, Σ)
"""

# ╔═╡ c1c9294e-2c7a-4f4d-915e-657a7bb17cfd
md"""
Each of the components of μ describes the mean of the corresponding dimension in feature space. The covariance matrix Σ is "shape" of the distribution in that dimension, defined as:
"""

# ╔═╡ bdadf89a-8f6f-4365-a6b5-aadc02dbb7f1
L"""
	Σ = cov(xᵢ, xⱼ) = ⟨(xᵢ - μᵢ)(xⱼ - μⱼ)ᵀ⟩
"""

# ╔═╡ 559628fd-f430-4451-9fa2-27c322919fca
md"note -- this tells us how correlate the different random variables are!"

# ╔═╡ f48b3498-b046-4b69-913d-755e363b127e
md"""
	(c) Covariance and Kernel functions
"""

# ╔═╡ bd2f75ce-a4ad-4ce5-b01d-21bb87538085


# ╔═╡ 275327ae-4461-4084-8f08-eb9f126dda00
md"""
### 1.2 Multi-output GP
	(a) Some strategies for implementation
	(b) How to account for correlation between outputs
"""

# ╔═╡ 8c1a97be-4954-41c6-b76b-b42183a045e9


# ╔═╡ 4ce23d34-a9be-493b-9eb4-dcad2fa35ccc
md"""
### 1.3 Simple example
	(a) I have no idea what this is going to be yet
	(b) How does this relate to my current project
"""

# ╔═╡ cd23e545-7221-49a2-9184-0cbcb841d8d1
begin
	@sk_import gaussian_process : GaussianProcessRegressor
	@sk_import gaussian_process.kernels : Matern
end

# ╔═╡ 4ab82681-1bea-4f7b-b038-b7110234b55d


# ╔═╡ 17e6945f-6745-4f75-b331-bc1b2a24bcf0
md"""
------------------------------------------------------------------------------------
## Part 2: Multi-fidelity Bayesian Optimization
### 2.1 Review of BO
	(a) review the search algorithm (figure form paper is really good for this)
		- objective function
		- acquisition function
		- test
	(a) Bayes Rule?
		- Shoud I re-derive this?
		- What are the parts of Bayes Rule; and, what do they mean?
	(c) Explain why it is relevant and how it is used to inform the search process.
"""

# ╔═╡ bec28490-0a2c-4c06-b26f-09d451d77eb7
md"**The Bayesian fomulation is to quantify the uncertainty of the unknown, black-box function with data.**"

# ╔═╡ 52e2eb62-dcbc-4ba5-bd76-2e8140f77acb
md"Baye's Rule:"

# ╔═╡ 7751f518-104f-4bcf-976e-894a39ea0a63
L"""
$$
Pr(\theta | y) = \frac{Pr(y | \theta) Pr(\theta)}{Pr(y)}
$$

$$
Pr(\theta | y) \propto Pr(y | \theta) Pr(\theta)
$$
"""

# ╔═╡ 3b3cfb03-1e17-4bb5-af9a-96193a066b1e


# ╔═╡ d6dc9728-6eb9-47af-8ead-2c983c2e5454
md"""Explotation-Exploitation trade-off: $(LocalResource("./figs/exploration_exploitation_balance_EI.png"))"""

# ╔═╡ 79a4d88c-1ff1-41af-8c22-86995dd4a500
md"""Explotation-Exploitation trade-off: $(LocalResource("./figs/search_efficientcy_curve_EI.png"))"""

# ╔═╡ edf8a612-f709-485a-8314-c3692f853823
md"""
### 2.2. Multi-fidelity BO
	(a) What do I mean when I say "fidelity"? How does that translate to my work?
	(b) What is the Expectied Improvement (EI) acquisition function?
		- definition (and -- time permitting -- derivation)
"""

# ╔═╡ 4dfdb404-ef5e-4168-8c73-b0d079609059


# ╔═╡ 5fb4b058-f6b6-4b80-843f-9c84b30f5dc5
md"""
### 2.3 Implementation in my current work
"""

# ╔═╡ 016a763b-bbcc-486d-9339-e189e65cf6e7


# ╔═╡ e174572e-d44b-4dba-9e6f-31c3a297ff66


# ╔═╡ cfa6d959-a5e5-4fdb-bcb5-cd0466c19d63
md"""
## Resources:
- [A Visual Exploration of Gaussian Processes](https://distill.pub/2019/visual-exploration-gaussian-processes/#Multivariate): interactive, intuitive blogpost 

- [Gaussian Processes for Machine Learning](http://www.gaussianprocess.org/gpml/chapters/RW.pdf): canonical GP textbook

- [Exploring Bayesian Optimization](https://distill.pub/2020/bayesian-optimization/): interactive blogpost that helps builds intuition

- [Bayesian Optimization](https://bayesoptbook.com/book/bayesoptbook.pdf): textbook

- [Bayesian optimization of nanoporous materials](https://doi.org/10.1039/D1ME00093D): Cory's paper
"""

# ╔═╡ c25fc58e-decc-4ec0-89c6-ee166798b829
md"There are so many more resources that could to be added, but these are what helped me the most"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
JLD2 = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee"
ScikitLearn = "3646fa90-6ef7-5e7e-9f22-8aca16db6324"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
Distributions = "~0.25.24"
JLD2 = "~0.4.15"
PlutoUI = "~0.7.18"
PyCall = "~1.92.5"
PyPlot = "~2.10.0"
ScikitLearn = "~0.6.4"
StatsBase = "~0.33.12"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0ec322186e078db08ea3e7da5b8b2885c099b393"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.0"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f885e7e7c124f8c92650d61b9477b9ac2ee607dd"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.1"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Conda]]
deps = ["JSON", "VersionParsing"]
git-tree-sha1 = "299304989a5e6473d985212c28928899c74e9421"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.5.2"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "72dcda9e19f88d09bf21b5f9507a0bb430bce2aa"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.24"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "2db648b6712831ecb333eae76dbfd1c156ca13bb"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.2"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "5efcf53d798efede8fee5b2c8b09284be359bf24"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.2"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "f0c6489b12d28fb4c2103073ec7452f3423bd308"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.1"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLD2]]
deps = ["DataStructures", "FileIO", "MacroTools", "Mmap", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "46b7834ec8165c541b0b5d1c8ba63ec940723ffb"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.15"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "6193c3815f13ba1b78a51ce391db8be016ae9214"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.4"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "c8b8775b2f242c80ea85c83714c64ecfa3c53355"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.3"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "57312c7ecad39566319ccf5aa717a20788eb8c1f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.18"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a193d6ad9c45ada72c14b731a318bedd3c2f00cf"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.3.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "d940010be611ee9d67064fe559edbb305f8cc0eb"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "4ba3651d33ef76e24fef6a598b63ffd1c5e1cd17"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.92.5"

[[PyPlot]]
deps = ["Colors", "LaTeXStrings", "PyCall", "Sockets", "Test", "VersionParsing"]
git-tree-sha1 = "14c1b795b9d764e1784713941e787e1384268103"
uuid = "d330b81b-6aea-500a-939a-2ce795aea3ee"
version = "2.10.0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[ScikitLearn]]
deps = ["Compat", "Conda", "DataFrames", "Distributed", "IterTools", "LinearAlgebra", "MacroTools", "Parameters", "Printf", "PyCall", "Random", "ScikitLearnBase", "SparseArrays", "StatsBase", "VersionParsing"]
git-tree-sha1 = "ccb822ff4222fcf6ff43bbdbd7b80332690f168e"
uuid = "3646fa90-6ef7-5e7e-9f22-8aca16db6324"
version = "0.6.4"

[[ScikitLearnBase]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "7877e55c1523a4b336b433da39c8e8c08d2f221f"
uuid = "6e75b9c4-186b-50bd-896f-2d2496a4843e"
version = "0.5.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "f0bccf98e16759818ffc5d97ac3ebf87eb950150"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.1"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

[[StatsFuns]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "95072ef1a22b057b1e80f73c2a89ad238ae4cfff"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.12"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[VersionParsing]]
git-tree-sha1 = "e575cf85535c7c3292b4d89d89cc29e8c3098e47"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.2.1"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─546656d5-48de-41fc-91f7-1da6a2e1fbc2
# ╠═358c0f22-977a-4388-9a90-fdccde3d2828
# ╟─498463b9-f73f-40ba-aa2f-eebd545d8dc9
# ╟─a9850e5c-a28f-49f7-8fb6-d0358b440996
# ╟─126e90be-757e-4c76-a0a1-4d1bdc68b089
# ╟─15f17cfe-ed5e-48e0-83e1-79382a85cb08
# ╟─15066ae2-ea35-4353-ad03-fad595019c34
# ╟─d5e92de2-4bd4-4882-80bb-6a34e0b14258
# ╠═e920b1b8-dd14-4dd8-b4e7-250074602c45
# ╟─73e98915-09ff-4bef-b474-d28f2a43bee7
# ╟─60a81b29-678d-46fb-adf4-e67a6f11b7c5
# ╟─2634b302-4b64-442f-b2bf-61b8d2bfa93e
# ╟─c1c9294e-2c7a-4f4d-915e-657a7bb17cfd
# ╟─bdadf89a-8f6f-4365-a6b5-aadc02dbb7f1
# ╟─559628fd-f430-4451-9fa2-27c322919fca
# ╟─f48b3498-b046-4b69-913d-755e363b127e
# ╠═bd2f75ce-a4ad-4ce5-b01d-21bb87538085
# ╟─275327ae-4461-4084-8f08-eb9f126dda00
# ╠═8c1a97be-4954-41c6-b76b-b42183a045e9
# ╟─4ce23d34-a9be-493b-9eb4-dcad2fa35ccc
# ╠═cd23e545-7221-49a2-9184-0cbcb841d8d1
# ╠═4ab82681-1bea-4f7b-b038-b7110234b55d
# ╟─17e6945f-6745-4f75-b331-bc1b2a24bcf0
# ╟─bec28490-0a2c-4c06-b26f-09d451d77eb7
# ╟─52e2eb62-dcbc-4ba5-bd76-2e8140f77acb
# ╟─7751f518-104f-4bcf-976e-894a39ea0a63
# ╠═3b3cfb03-1e17-4bb5-af9a-96193a066b1e
# ╟─d6dc9728-6eb9-47af-8ead-2c983c2e5454
# ╟─79a4d88c-1ff1-41af-8c22-86995dd4a500
# ╟─edf8a612-f709-485a-8314-c3692f853823
# ╠═4dfdb404-ef5e-4168-8c73-b0d079609059
# ╟─5fb4b058-f6b6-4b80-843f-9c84b30f5dc5
# ╠═016a763b-bbcc-486d-9339-e189e65cf6e7
# ╠═e174572e-d44b-4dba-9e6f-31c3a297ff66
# ╟─cfa6d959-a5e5-4fdb-bcb5-cd0466c19d63
# ╟─c25fc58e-decc-4ec0-89c6-ee166798b829
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
