# Build the parameters type and p₀
t = empty_parameter_table()    # initialize table of parameters
add_parameter!(t, :xgeo, 2.17u"mmol/m^3",
    variance_obs = ustrip(upreferred(0.1 * 2.17u"mmol/m^3"))^2,
    description = "Geological mean P concentration",
    LaTeX = "\\state^\\mathrm{geo}")
add_parameter!(t, :τgeo, 1.0u"Myr",
    description = "Geological restoring timescale",
    LaTeX = "\\tau_\\mathrm{geo}")
add_parameter!(t, :k, 10.0u"μmol/m^3",
    optimizable = true,
    description = "Half-saturation constant (Michaelis-Menten)",
    LaTeX = "k_\\vec{u}")
add_parameter!(t, :z₀, 80.0u"m",
    description = "Depth of the euphotic layer base",
    LaTeX = "z_0")
add_parameter!(t, :w₀, 1.0u"m/d",
    optimizable = true,
    description = "Sinking velocity at surface",
    LaTeX = "w_0")
add_parameter!(t, :w′, 1/4.4625u"d",
    optimizable = true,
    description = "Vertical gradient of sinking velocity",
    LaTeX = "w'")
add_parameter!(t, :κDOP, 1/0.25u"yr",
    optimizable = true,
    description = "Remineralization rate constant (DOP to DIP)",
    LaTeX = "\\kappa")
add_parameter!(t, :κPOP, 1/5.25u"d",
    optimizable = true,
    description = "Dissolution rate constant (POP to DOP)",
    LaTeX = "\\kappa")
add_parameter!(t, :σ, 0.3u"1",
    description = "Fraction of quick local uptake recycling",
    LaTeX = "\\sigma")
add_parameter!(t, :τ, 30.0u"d",
    optimizable = true,
    description = "Maximum uptake rate timescale",
    LaTeX = "\\tau_\\vec{u}")
add_parameter!(t, :foo, 1.0u"m")
delete_parameter!(t, :foo)
add_parameter!(t, :foo, 1.0u"m")
delete_parameter!(t, size(t, 1))
initialize_Parameters_type(t)   # Generate the parameter type
p₀ = Parameters()
m_all = length(fieldnames(typeof(p₀)))
m = length(p₀)

@testset "Parameters" begin
    @test t isa DataFrames.DataFrame
    @test_throws ErrorException initialize_Parameters_type(t)
    @test_throws ErrorException add_parameter!(t, :τ, 30.0u"d")
    @test_throws ErrorException delete_parameter!(t, :not_a_parameter)
    @test size(t) == (m_all, 9) # m_all is # of params
    @test size(p₀) == (m,)
    @test length(p₀) == m
    println(p₀)
    @test p₀ isa AIBECS.Parameters{Float64}
    using DualNumbers, HyperDualNumbers
    println(p₀ * im)
    @test p₀ * im isa AIBECS.Parameters{Complex{Float64}}
    println(p₀ * ε)
    @test p₀ * ε isa AIBECS.Parameters{Dual{Float64}}
    println(p₀ * ε₁)
    @test p₀ * ε₁ isa AIBECS.Parameters{Hyper{Float64}}
end
