# module test_sugarcubes_femtocompier_typeinf_edge

using Test
using Pkg # Pkg.devdir
using SugarCubes: code_block_with, has_diff

src_path = "sources/Compiler/src/typeinfer.jl"
src_signature = :(function typeinf_edge(interp::AbstractInterpreter, method::Method, @nospecialize(atype), sparams::SimpleVector, caller::AbsIntState, edgecycle::Bool, edgelimited::Bool) end)
dest_path = "FemtoCompiler/ext/typeinfer.jl"
dest_signature = :(function typeinf_edge(interp::FemtoInterpreter, method::Method, @nospecialize(atype), sparams::SimpleVector, caller::AbsIntState, edgecycle::Bool, edgelimited::Bool) end)

src_filepath = normpath(@__DIR__, "../../", src_path)
dest_filepath = normpath(Pkg.devdir(), dest_path)
@test isfile(src_filepath)
@test isfile(dest_filepath)
src_block = code_block_with(; filepath = src_filepath, signature = src_signature)
dest_block = code_block_with(; filepath = dest_filepath, signature = dest_signature)

using SugarCubes: get_func_block
src_range = get_func_block(src_block)
@test src_range !== nothing
dest_range = get_func_block(dest_block)
@test dest_range !== nothing

@test has_diff(src_block, dest_block) === false

# end # module test_sugarcubes_femtocompier_typeinf_edge
