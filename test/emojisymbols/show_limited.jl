module test_emojisymbols_show_limited

using Test
using SugarCubes: CodeBlock, code_block_with, get_func_block_range, has_diff

# from julia/stdlib/REPL/src/REPL.jl

src_code = raw"""
"doc"
module REPL

function show_limited(io::IO, mime::MIME, x)
    try
        # We wrap in a LimitIO to limit the amount of printing.
        # We unpack `IOContext`s, since we will pass the properties on the outside.
        inner = io isa IOContext ? io.io : io
        wrapped_limiter = IOContext(LimitIO(inner, SHOW_MAXIMUM_BYTES), io)
        # `show_repl` to allow the hook with special syntax highlighting
        show_repl(wrapped_limiter, mime, x)
    catch e
        e isa LimitIOException || rethrow()
        printstyled(io, "…[printing stopped after displaying $(Base.format_bytes(e.maxbytes)); call `show(stdout, MIME"text/plain"(), ans)` to print without truncation]"; color=:light_yellow, bold=true)
    end
end

end # module
"""
src_signature = :(module REPL function show_limited(io::IO, mime::MIME, x) end end)
src_block = CodeBlock(src_code, "REPL.jl", src_signature)

src_range = get_func_block_range(src_block)
@test src_range !== nothing

end # module test_emojisymbols_show_limited
