module test_sugarcubes_to_signature

using Test
using SugarCubes: to_signature

sig = to_signature(:(function f(x::MyInt, y::Int) end))
@test length(sig.layers) == 1

sig = to_signature(:(if VERSION >= v"1.12" function f(x::MyInt, y::Int) end end))
@test length(sig.layers) == 2

sig = to_signature(:(if VERSION >= v"1.13.0-DEV.620" elseif VERSION >= v"1.11.0" function f(x::MyInt, y::Int) end end))
@test length(sig.layers) == 2

sig = to_signature(:(module Test macro test(ex, kws...) end end))
@test length(sig.layers) == 2

sig = to_signature(:(module TestExt if VERSION >= v"1.14.0-DEV.1453" elseif VERSION >= v"1.11" macro test(ex, kws::Expr...) end end end))
@test length(sig.layers) == 3

end # module test_sugarcubes_to_signature
