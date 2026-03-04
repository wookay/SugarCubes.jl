module test_sugarcubes_code_block

using Test
using Pkg # Pkg.devdir
using SugarCubes # @code_block
using Meringues # ≈

src_path = normpath(@__DIR__, "../../sources/Compiler/src/abstractinterpretation.jl")
src_block = @code_block src_path function typeinf_local(interp::AbstractInterpreter, frame::InferenceState, nextresult::CurrentState) end
@test isfile(src_path)
@test src_block.filepath == src_path
@test src_block.signature ≈ :(function typeinf_local(interp::AbstractInterpreter, frame::InferenceState, nextresult::CurrentState) end)

dest_path = normpath(Pkg.devdir(), "FemtoCompiler/ext/abstractinterpretation.jl")
dest_block = CodeBlock(dest_path, :(function typeinf_local(interp::FemtoInterpreter, frame::InferenceState, nextresult::CurrentState) end))
@test isfile(dest_path)
@test dest_block.filepath == dest_path
@test dest_block.signature ≈ :(function typeinf_local(interp::FemtoInterpreter, frame::InferenceState, nextresult::CurrentState) end)

end # module test_sugarcubes_code_block
