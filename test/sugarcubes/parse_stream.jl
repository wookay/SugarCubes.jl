module test_sugarcubes_parse_stream

using Test
using JuliaSyntax: JuliaSyntax as JS
using .JS: ParseStream, GreenNode, SyntaxHead, parseall

code = """
# comment 1

function f()
end
# comment 2
"""
st = ParseStream(code)

ex = parseall(Expr, code)
@test ex isa Expr

t = parseall(GreenNode, code)
@test t isa GreenNode{SyntaxHead}

end # module test_sugarcubes_parse_stream
