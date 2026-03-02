using Test
using JuliaSyntax: JuliaSyntax as JS
using .JS: SourceFile
using .JS: parsestmt, sourcefile, filename, source_location, source_line, sourcetext, highlight
using Meringues # ≈

# from  julia/JuliaSyntax/test/syntax_graph.jl
using .JS: SyntaxTree
st = parsestmt(SyntaxTree, "function foo end")
@test st isa SyntaxTree{Dict{Symbol, Any}}
@test sourcefile(st) isa SourceFile
@test isempty(filename(st))
@test source_location(st) == (1, 1)
@test source_line(st) == 1
@test sourcetext(st) == "function foo end"
highlight(devnull, st)

# from  julia/JuliaSyntax/test/syntax_node.jl
using .JS: SyntaxNode, to_expr
t = parsestmt(SyntaxNode, "function foo end")
@test source_location(t) == (1, 1)
@test source_line(t) == 1
@test sourcetext(t) == "function foo end"
@test to_expr(t) ≈ :(function foo end)

# show(stdout, MIME("text/plain"), t, show_location=true)

buf = IOBuffer()
show(buf, MIME("text/plain"), t, show_location=true)
@test String(take!(buf)) == """
SyntaxNode:
line:col│ byte_range  │ tree
   1:1  │     1:16    │[function]
   1:10 │    10:12    │  foo                                    :: Identifier
"""

show(buf, MIME("text/plain"), t, show_location=false)
@test String(take!(buf)) == """
SyntaxNode:
[function]
  foo                                    :: Identifier
"""
