on_ci = haskey(ENV, "CI")
if on_ci
    using Pkg
    Pkg.develop("FemtoCompiler")
end

using Jive
runtests(@__DIR__, into=Main)
