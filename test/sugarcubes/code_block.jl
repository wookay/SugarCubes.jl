module test_sugarcubes_code_block

using Test
using SugarCubes
using SugarCubes: get_func_block

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
@test get_func_block(dest_block) == 2:2
@test get_func_block(dest_block) == 2:2 # keep signature layers

@test has_diff(src_block1, dest_block) === false
@test has_diff(src_block2, dest_block; show_diff = false) === true

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
@test has_diff(src_block2, dest_block3; show_diff = false) === true

dest_code3 = """
if VERSION >= v"1.13.0-DEV.620"
elseif VERSION >= v"1.11.0"
function f(x::Int, y::Int)
    xs + 2
end
function f(x::MyInt, y::Int)
    xs + 3
end
end
"""
dest_signature3 = :(if VERSION >= v"1.13.0-DEV.620" elseif VERSION >= v"1.11.0" function f(x::MyInt, y::Int) end end)
dest_block3 = CodeBlock(dest_code3, "dest_code3.jl", dest_signature3)

dest_range = get_func_block(dest_block3)
@test dest_range !== nothing

dest_code3 = """
if VERSION >= v"1.13.0-DEV.620"
elseif VERSION >= v"1.12.0-DEV.901"
elseif VERSION >= v"1.11.0"
function f(x::Int, y::Int)
    xs + 2
end
function f(x::MyInt, y::Int)
    xs + 3
end
end
"""
dest_signature3 = :(if VERSION >= v"1.13.0-DEV.620" elseif VERSION >= v"1.11.0" function f(x::MyInt, y::Int) end end)
dest_block3 = CodeBlock(dest_code3, "dest_code3.jl", dest_signature3)

dest_range = get_func_block(dest_block3)
@test dest_range !== nothing

dest_code4 = """
if VERSION >= v"1.13.0-DEV.620"
else
function f(x::Int, y::Int)
    xs + 2
end
function f(x::MyInt, y::Int)
    xs + 3
end
end
"""
dest_signature4 = :(if VERSION >= v"1.13.0-DEV.620" else function f(x::MyInt, y::Int) end end)
dest_block4 = CodeBlock(dest_code4, "dest_code4.jl", dest_signature4)

using SugarCubes: get_func_block
dest_range = get_func_block(dest_block4)
@test dest_range !== nothing

src_code5 = """
module Test
"doc"
macro test(ex, kws...)
    if true
        if true
        else
            let _do = (length(broken) > 0 && esc(broken[1])) ? do_broken_test : do_test
                _do(result, ex, ctx)
            end
        end
    end
    return result
end # macro
end # module
"""
dest_code5 = """
module TestExt
if VERSION >= v"1.14.0-DEV.1453"
elseif VERSION >= v"1.11"
macro test(ex, kws::Expr...)
    if true
        if true
        else
            let _do = (length(broken) > 0 && esc(broken[1])) ? do_broken_test_ext : do_test_ext
                _do(result, ex, ctx)
            end
        end
    end
    return result
end # macro
end # if
end # module
"""
src_signature5 = :(module Test macro test(ex, kws...) end end)
src_block5 = CodeBlock(src_code5, "src_code5.jl", src_signature5)
dest_signature5 = :(module TestExt if VERSION >= v"1.14.0-DEV.1453" elseif VERSION >= v"1.11" macro test(ex, kws::Expr...) end end end)
dest_block5 = CodeBlock(dest_code5, "dest_code5.jl", dest_signature5)
@test has_diff(src_block5, dest_block5; show_diff = false) === true
@test has_diff(src_block5, dest_block5; skip_lines = (src = [-6], dest = [-6])) === false
@test has_diff(src_block5, dest_block5; skip_lines = (src = [4], dest = [4])) === false

end # module test_sugarcubes_code_block
