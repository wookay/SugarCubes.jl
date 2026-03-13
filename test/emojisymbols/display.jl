using Jive
@If VERSION >= v"1.14-DEV" module test_emojisymbols_display

using Test
using Pkg # Pkg.devdir
using SugarCubes: CodeBlock, code_block_with, get_func_block, has_diff

src_code = """
module REPL
function display(d::REPLDisplay, mime::MIME"text/plain", x)
end
end
"""
src_signature = :(module REPL function display(d::REPLDisplay, mime::MIME"text/plain", x) end end)
src_block = CodeBlock(src_code, "REPL.jl", src_signature)

src_range = get_func_block(src_block)
@test src_range !== nothing

dest_path = "EmojiSymbols/src/REPL.jl"
dest_signature = :(if VERSION >= v"1.13.0-DEV.620" elseif VERSION >= v"1.11.0" function display(d::REPLDisplay, mime::MIME"text/plain", x::AbstractChar) end end)

dest_filepath = normpath(Pkg.devdir(), dest_path)
@test isfile(dest_filepath)
dest_block = code_block_with(; filepath = dest_filepath, signature = dest_signature)

dest_range = get_func_block(dest_block)
@test dest_range !== nothing

@test has_diff(src_block, dest_block)

end # module test_emojisymbols_display
