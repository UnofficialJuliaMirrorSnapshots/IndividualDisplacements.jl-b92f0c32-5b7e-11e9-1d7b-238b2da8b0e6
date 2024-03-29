# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.4'
#       jupytext_version: 1.2.4
#   kernelspec:
#     display_name: Julia 1.1.0
#     language: julia
#     name: julia-1.1
# ---

# # This notebook
#
# A simplified version of `ex2_more.jl` used in `runtests.jl` (avoids downloading binary data).
#
# _Notes:_ For documentation see <https://gaelforget.github.io/MeshArrays.jl/stable/>, <https://docs.juliadiffeq.org/latest/solvers/ode_solve.html> and <https://en.wikipedia.org/wiki/Displacement_(vector)>

# ## 1. import software and `pkg/flt` trajectories

using IndividualDisplacements, MeshArrays, Plots, DifferentialEquations

# ## 2. Define gridded variables as `MeshArray`s

# Put grid variables in a dictionary:

# +
mygrid=gcmgrid("flt_example/","ll",1,[(80,42)], [80 42], Float32, read, write)
nr=8

XC=MeshArray(mygrid,Float32); XC[1]=vec(2500.:5000.:397500.0)*ones(1,42);
XG=MeshArray(mygrid,Float32); XG[1]=vec(0.:5000.:395000.0)*ones(1,42);
YC=MeshArray(mygrid,Float32); YC[1]=ones(80,1)*transpose(vec(2500.:5000.:207500.0));
YG=MeshArray(mygrid,Float32); YG[1]=ones(80,1)*transpose(vec(0.:5000.:205000.0));

GridVariables=Dict("XC" => XC,"YC" => YC,"XG" => XG,"YG" => YG,"dx" => 5000.0);
# -

# Put velocity fields in a dictionary:

# +
t0=0.0 #approximation / simplification
t1=18001.0*3600.0

u0=-(YG.-YC[1][40,21])/2000000.; u1=u0
v0=(XG.-XC[1][40,21])/2000000.; v1=v0

u0=u0./GridVariables["dx"]
u1=u1./GridVariables["dx"]
v0=v0./GridVariables["dx"]
v1=v1./GridVariables["dx"]

uvt = Dict("u0" => u0, "u1" => u1, "v0" => v0, "v1" => v1, "t0" => t0, "t1" => t1)
uvetc=merge(uvt,GridVariables);
# -

# ## 3. Define initial condition and time period

uInit=[200000.0;0.0]./uvetc["dx"]
nSteps=3000-2
du=fill(0.0,2);

# ## 4. solve through time using DifferentialEquations.jl

using DifferentialEquations
tspan = (0.0,nSteps*3600.0)
prob = ODEProblem(IndividualDisplacements.VelComp,uInit,tspan,uvetc)
sol = solve(prob,Tsit5(),reltol=1e-8,abstol=1e-8)
sol[1:4]

# ## 5. visualize trajectory

using Plots
Plots.plot(sol[1,:],sol[2,:],linewidth=5,title="Solid body rotation example",
     xaxis="lon",yaxis="lat",label="Julia Solution") # legend=false

# ## 6. check against reference result

sol[1,end],sol[2,end]
isapprox(sol[1,end],117237.0./uvetc["dx"]; atol=1.)
isapprox(sol[2,end],40448.0./uvetc["dx"]; atol=1.)


