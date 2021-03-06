module Primeau_2x2x2
#=
This circulation and grid was created by François Primeau (fprimeau@uci.edu)
It was taken from his Notebook at
https://github.com/fprimeau/BIOGEOCHEM_TEACHING/blob/master/Intro2TransportOperators.ipynb

The simple box model we consider is embeded in a 2×2×2 "shoebox".
It has 5 wet boxes and 3 dry boxes.
See image at
https://github.com/fprimeau/BIOGEOCHEM_TEACHING/blob/master/boxmodel.png
=#

using LinearAlgebra, SparseArrays
using ..GridTools
using Unitful, UnitfulAstro # for units
using Reexport
@reexport using OceanGrids            # To store the grid
using ..CirculationGeneration
CG = CirculationGeneration


function build_wet3D()
    wet3D = trues(2, 2, 2)
    wet3D[[4,7,8]] .= false # land points
    return wet3D
end


function build_grid()
    elon = [0,180,360] * u"°"
    elat = [-90, 0, 90] * u"°"
    edepth = [0, 200, 3700] * u"m"
    return OceanGrid(elon, elat, edepth)
end

function build_T(grid, wet3D)
    # From Archer et al. [2000]
    v3D = array_of_volumes(grid)
    nb = length(v3D)

    # Antarctic Circumpoloar Current 1 -> 3 -> 1
    ACC = 100e6u"m^3/s"
    T  = CG.flux_divergence_operator_from_advection(ACC, [1, 3], v3D, nb)
    # Meridional Overturning Circulation 1 -> 2 -> 6 -> 5 -> 1
    MOC = 15e6u"m^3/s"
    T += CG.flux_divergence_operator_from_advection(MOC, [1, 2, 6, 5], v3D, nb)
    # vertical mixing at "high northern latitudes" 2 <-> 6
    MIX = 10e6u"m^3/s"
    T += CG.flux_divergence_operator_from_advection(MIX, [2, 6], v3D, nb)

    # Only keep wet points
    iwet = findall(vec(wet3D))

    return T[iwet, iwet]
end


"""
    load

Returns wet3D, grd, and T (in that order).
"""
function load()
    print("Creating François Primeau's 2x2x2 model")
    wet3D = build_wet3D()
    grd = build_grid()
    T = build_T(grd, wet3D)
    println(" ✔")
    return wet3D, grd, ustrip.(T)
end

end

export Primeau_2x2x2

