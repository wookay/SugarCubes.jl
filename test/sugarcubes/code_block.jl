module test_sugarcubes_code_block

using Test
using SugarCubes

src_code1 = """
function f(x::Int, y::Int)
    xs
end
function g()
    xs
end
"""

src_code2 = """
function f(x::Int, y::Int)
    xs + 2
end
function g()
    xs
end
"""

src_signature = :(function f(x::Int, y::Int) end)
src_block1 = CodeBlock(src_code1, "src_code1.jl", src_signature)
src_block2 = CodeBlock(src_code2, "src_code2.jl", src_signature)

dest_code = """
function f(x::MyInt, y::Int)
    xs
end
"""
dest_signature = :(function f(x::MyInt, y::Int) end)
dest_block = CodeBlock(dest_code, "dest_code.jl", dest_signature)

@test has_diff(src_block1, dest_block) === false
@test has_diff(src_block2, dest_block) === true

dest_code2 = """
if VERSION >= v"1.12"
function f(x::Int, y::Int)
    xs + 2
end
function f(x::MyInt, y::Int)
    xs + 3
end
end
"""
dest_signature2 = :(if VERSION >= v"1.12" function f(x::Int, y::Int) end end)
dest_block2 = CodeBlock(dest_code2, "dest_code2.jl", dest_signature2)
dest_signature3 = :(if VERSION >= v"1.12" function f(x::MyInt, y::Int) end end)
dest_block3 = CodeBlock(dest_code2, "dest_code2.jl", dest_signature3)

@test has_diff(src_block2, dest_block2) === false
@test has_diff(src_block2, dest_block3) === true

end # module test_sugarcubes_code_block
