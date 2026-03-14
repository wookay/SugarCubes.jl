# module SugarCubes


# SugarCubes.CodeBlock
precompile(Tuple{Type{SugarCubes.CodeBlock}, String, String, Expr})
precompile(Tuple{typeof(SugarCubes.get_func_block), SugarCubes.CodeBlock})
precompile(Tuple{typeof(SugarCubes.has_diff), SugarCubes.CodeBlock, SugarCubes.CodeBlock})
precompile(Tuple{Type{NamedTuple{(:skip_lines,), T} where T<:Tuple}, Tuple{Array{Int64, 1}}})
precompile(Tuple{typeof(Core.kwcall), NamedTuple{(:skip_lines,), Tuple{Array{Int64, 1}}}, typeof(SugarCubes.has_diff), SugarCubes.CodeBlock, SugarCubes.CodeBlock})
precompile(Tuple{typeof(SugarCubes.to_signature), Expr})
precompile(Tuple{typeof(Base.getproperty), SugarCubes.Signature, Symbol})
precompile(Tuple{typeof(Base.length), Array{Tuple{Int64, SugarCubes.JS.Kind, Expr}, 1}})
precompile(Tuple{typeof(SugarCubes.get_func_block), SugarCubes.CodeBlock, SugarCubes.Signature})

# module SugarCubes
