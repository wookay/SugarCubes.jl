module SugarCubes

export CodeBlock, code_block_with, has_diff
include("code_block.jl")
Base.generating_output() && include("precompile.jl")

end # module SugarCubes
