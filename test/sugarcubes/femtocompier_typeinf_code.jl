module test_sugarcubes_femtocompier_typeinf_code

using Test
using Pkg # Pkg.devdir
using SugarCubes: code_block_with, has_diff
using Meringues # ≈

src_path = normpath(@__DIR__, "../../sources/Compiler/src/abstractinterpretation.jl")
@test isfile(src_path)
src_signature = :(function typeinf_local(interp::AbstractInterpreter, frame::InferenceState, nextresult::CurrentState) end)
src_block = code_block_with(; filepath = src_path, signature = src_signature)
@test src_block.signature ≈ :(function typeinf_local(interp::AbstractInterpreter, frame::InferenceState, nextresult::CurrentState) end)

dest_path = normpath(Pkg.devdir(), "FemtoCompiler/ext/abstractinterpretation.jl")
dest_signature = :(function typeinf_local(interp::FemtoInterpreter, frame::InferenceState, nextresult::CurrentState) end)
dest_block = code_block_with(; filepath = dest_path, signature = dest_signature)

using SugarCubes: get_func_block
dest_range = get_func_block(dest_block)
@test dest_range !== nothing

@test has_diff(src_block, dest_block) === false

end # module test_sugarcubes_femtocompier_typeinf_code
