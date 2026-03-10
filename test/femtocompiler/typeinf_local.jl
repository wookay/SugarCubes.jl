module test_femtocompiler_typeinf_local

using Test
using Pkg # Pkg.devdir
using SugarCubes: code_block_with, has_diff

src_path = "sources/Compiler/src/abstractinterpretation.jl"
src_signature = :(function typeinf_local(interp::AbstractInterpreter, frame::InferenceState, nextresult::CurrentState) end)
dest_path = "FemtoCompiler/ext/abstractinterpretation.jl"
dest_signature = :(function typeinf_local(interp::FemtoInterpreter, frame::InferenceState, nextresult::CurrentState) end)

src_filepath = normpath(@__DIR__, "../../", src_path)
dest_filepath = normpath(Pkg.devdir(), dest_path)
@test isfile(src_filepath)
@test isfile(dest_filepath)
src_block = code_block_with(; filepath = src_filepath, signature = src_signature)
dest_block = code_block_with(; filepath = dest_filepath, signature = dest_signature)

using SugarCubes: remove_linenums_in_macrocall!, get_func_block
@test src_block.signature.func == remove_linenums_in_macrocall!(:(function typeinf_local(interp::AbstractInterpreter, frame::InferenceState, nextresult::CurrentState) end))

dest_range = get_func_block(dest_block)
@test dest_range !== nothing

@test has_diff(src_block, dest_block) === false

end # module test_femtocompiler_typeinf_local
