module SugarCubes

using JuliaSyntax: JuliaSyntax as JS

export CodeBlock
include("types.jl")

export remove_linenums_in_macrocall!
include("expr.jl")

export code_block_with, has_diff
include("code_block.jl")

Base.generating_output() && include("precompile.jl")

end # module SugarCubes
