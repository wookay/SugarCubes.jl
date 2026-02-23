using Test
using Pkg # Pkg.devdir
using SugarCubes # @code_block
using Meringues # ≈

src_path = normpath(@__DIR__, "../../sources/Compiler/src/abstractinterpretation.jl")
src_block = @code_block src_path function typeinf_local(interp::AbstractInterpreter, frame::InferenceState, nextresult::CurrentState) end
@test isfile(src_path)
@test src_block.filepath == src_path
@test src_block.signature ≈ :(function typeinf_local(interp::AbstractInterpreter, frame::InferenceState, nextresult::CurrentState) end)

dst_path = normpath(Pkg.devdir(), "FemtoCompiler/ext/abstractinterpretation.jl")
dst_block = @code_block dst_path function typeinf_local(interp::FemtoInterpreter, frame::InferenceState, nextresult::CurrentState) end
@test dst_block.filepath == dst_path
@test dst_block.signature ≈ :(function typeinf_local(interp::FemtoInterpreter, frame::InferenceState, nextresult::CurrentState) end)
