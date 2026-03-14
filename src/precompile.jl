# module SugarCubes

using JuliaSyntax: JuliaSyntax

# SugarCubes.CodeBlock
precompile(Tuple{Type{SugarCubes.CodeBlock}, String, String, Expr})
precompile(Tuple{typeof(SugarCubes.get_func_block), SugarCubes.CodeBlock})
precompile(Tuple{typeof(SugarCubes.has_diff), SugarCubes.CodeBlock, SugarCubes.CodeBlock})
precompile(Tuple{Type{NamedTuple{(:src, :dest), T} where T<:Tuple}, Tuple{Array{Int64, 1}, Array{Int64, 1}}})
precompile(Tuple{Type{NamedTuple{(:skip_lines,), T} where T<:Tuple}, Tuple{NamedTuple{(:src, :dest), Tuple{Array{Int64, 1}, Array{Int64, 1}}}}})
precompile(Tuple{typeof(Core.kwcall), NamedTuple{(:skip_lines,), Tuple{NamedTuple{(:src, :dest), Tuple{Array{Int64, 1}, Array{Int64, 1}}}}}, typeof(SugarCubes.has_diff), SugarCubes.CodeBlock, SugarCubes.CodeBlock})
precompile(Tuple{typeof(SugarCubes.to_signature), Expr})
precompile(Tuple{typeof(SugarCubes.get_func_block), SugarCubes.CodeBlock, SugarCubes.Signature})
precompile(Tuple{typeof(Base.getproperty), SugarCubes.Signature, Symbol})
precompile(Tuple{typeof(Base.length), Array{Tuple{Int64, JuliaSyntax.Kind, Expr}, 1}})
precompile(Tuple{Type{NamedTuple{(:filepath, :signature), T} where T<:Tuple}, Tuple{String, Expr}})
precompile(Tuple{typeof(Core.kwcall), NamedTuple{(:filepath, :signature), Tuple{String, Expr}}, typeof(SugarCubes.code_block_with)})
precompile(Tuple{typeof(Base.setproperty!), Expr, Symbol, Array{Union{Nothing, Symbol}, 1}})
precompile(Tuple{typeof(Base.getproperty), SugarCubes.CodeBlock, Symbol})
precompile(Tuple{typeof(Base.lastindex), Array{Tuple{Int64, JuliaSyntax.Kind, Expr}, 1}})
precompile(Tuple{typeof(Base.getindex), Array{Tuple{Int64, JuliaSyntax.Kind, Expr}, 1}, Int64})
precompile(Tuple{typeof(Base.indexed_iterate), Tuple{Int64, JuliaSyntax.Kind, Expr}, Int64})
precompile(Tuple{typeof(Base.indexed_iterate), Tuple{Int64, JuliaSyntax.Kind, Expr}, Int64, Int64})

# module SugarCubes
