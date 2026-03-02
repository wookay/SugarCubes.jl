module test_sugarcubes_expr

using Test
using JuliaSyntax: JuliaSyntax as JS
using .JS: parsestmt

# from julia/JuliaSyntax/test/expr.jl
@test parsestmt(Expr, """
function f()
    xs
end
""") ==
    Expr(:function,
         Expr(:call, :f),
         Expr(:block,
              LineNumberNode(1),
              LineNumberNode(2),
              :xs))

@test parsestmt(Expr, """f() = xs""") ==
    Expr(:(=),
         Expr(:call, :f),
         Expr(:block,
              LineNumberNode(1),
              :xs))

end # module test_sugarcubes_expr
