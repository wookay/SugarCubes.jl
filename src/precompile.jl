# module SugarCubes

# SugarCubes.CodeBlock
precompile(Tuple{Type{SugarCubes.CodeBlock}, String, String, Expr})
precompile(Tuple{typeof(Base.getproperty), SugarCubes.CodeBlock, Symbol})
precompile(Tuple{typeof(SugarCubes.has_diff), SugarCubes.CodeBlock, SugarCubes.CodeBlock})
precompile(Tuple{typeof(SugarCubes.get_parsed_expr), SugarCubes.CodeBlock})
precompile(Tuple{typeof(SugarCubes.get_func_block), SugarCubes.CodeBlock})
precompile(Tuple{Type{NamedTuple{(:filepath, :signature), T} where T<:Tuple}, Tuple{String, Expr}})
precompile(Tuple{typeof(Core.kwcall), NamedTuple{(:filepath, :signature), Tuple{String, Expr}}, typeof(SugarCubes.code_block_with)})

# Expr
precompile(Tuple{typeof(SugarCubes.to_signature), Expr})
precompile(Tuple{typeof(SugarCubes.matched_lines), Expr, Expr})
precompile(Tuple{typeof(SugarCubes.remove_linenums_in_macrocall!), Expr})

precompile(Tuple{typeof(SugarCubes.get_lines), String, UnitRange{Int}})

# module SugarCubes
