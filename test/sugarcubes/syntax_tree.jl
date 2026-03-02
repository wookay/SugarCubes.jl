module test_sugarcubes_syntax_tree

using Test
using JuliaSyntax: JuliaSyntax as JS
using .JS: SyntaxTree, parsestmt, @K_str

st = parsestmt(SyntaxTree, """
function f()
    xs
end
""")
@test st.kind == K"function"
@test JS.numchildren(st) == 2
@test st[1].kind == K"call"
@test st[1][1].kind == K"Identifier"
@test st[1][1].name_val == "f"
@test st[2].kind == K"block"
@test st[2][1].kind == K"Identifier"
@test st[2][1].name_val == "xs"
JS.highlight(devnull, st[1][1])
# function f()
# #        ╙
#     xs
# end
JS.highlight(devnull, st[2][1])
# function f()
#     xs
# #   └┘
# end

st = parsestmt(SyntaxTree, """f() = xs""")
@test st.kind == K"="
@test JS.numchildren(st) == 2
@test st[1].kind == K"call"
@test st[1][1].kind == K"Identifier"
@test st[1][1].name_val == "f"
@test st[2].kind == K"block"
@test st[2][1].kind == K"Identifier"
@test st[2][1].name_val == "xs"
JS.highlight(devnull, st[1][1])
# f() = xs
# ╙
JS.highlight(devnull, st[2][1])
# f() = xs
# #     └┘

end # module test_sugarcubes_syntax_tree
