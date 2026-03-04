module test_sugarcubes_stm

using Test
using JuliaSyntax: JuliaSyntax as JS
using .JS: SyntaxTree, parseall, @K_str, @stm

M = Module(:TestMod)
src = """
function f()
    xs
end
function g()
    xs
end
"""

ex = parseall(SyntaxTree, src)
@test JS.kind(ex) == K"toplevel"
@test JS.numchildren(ex) == 2

call_blocks = map(JS.children(ex)) do child
    @stm child begin
        [K"function" call block] -> (call, block)
    end
end

(call_f, block) = call_blocks[1]
@test call_f.kind == K"call"
@test call_f[1].kind == K"Identifier"
@test call_f[1].name_val == "f"
@test block.kind == K"block"
@test block[1].source isa JS.SourceRef
@test block[1].source.first_byte == 18
@test block[1].source.last_byte == 19

(call_g, block) = call_blocks[2]
@test call_g[1].name_val == "g"

end # module test_sugarcubes_stm
