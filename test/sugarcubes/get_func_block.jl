module test_sugarcubes_get_func_block

using Test
using SugarCubes: CodeBlock, to_signature, get_func_block

src_code = """
function f(x::Int, y::Int)
    xs
end
function f(x::MyInt, y::Int)
    xs + 2
end
"""
src_signature = :(function f(x::Int, y::Int) end)
src_block = CodeBlock(src_code, "src_code.jl", src_signature)
@test get_func_block(src_block) == 2:2

src_signature = :(function f(x::MyInt, y::Int) end)
@test get_func_block(src_block, to_signature(src_signature)) == 5:5

src_code = """
"doc"
module REPL

function show_limited(io::IO, mime::MIME, x)
    xs
end

end # module
"""
src_signature = :(module REPL function show_limited(io::IO, mime::MIME, x) end end)
src_block = CodeBlock(src_code, "src_code.jl", src_signature)
@test get_func_block(src_block) == 5:5

src_code = """
module REPL
function show_limited(io::IO, mime::MIME, x)
    xs
end
end # module
"""
src_signature = :(module REPL function show_limited(io::IO, mime::MIME, x) end end)
src_block = CodeBlock(src_code, "src_code.jl", src_signature)
@test get_func_block(src_block) == 3:3

src_code = """
"doc"
module Test

macro test(ex, kws...)
    xs
end

end # module
"""
src_signature = :(module Test macro test(ex, kws...) end end)
src_block = CodeBlock(src_code, "src_code.jl", src_signature)
@test get_func_block(src_block) == 5:5

src_code = """
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

dest_code = """
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
src_signature = :(module Test macro test(ex, kws...) end end)
src_block = CodeBlock(src_code, "src_code.jl", src_signature)
dest_signature = :(module TestExt if VERSION >= v"1.14.0-DEV.1453" elseif VERSION >= v"1.11" macro test(ex, kws::Expr...) end end end)
dest_block = CodeBlock(dest_code, "dest_code.jl", dest_signature)

@test get_func_block(src_block) == 4:12
@test get_func_block(dest_block) == 5:13

dest_code = """
if VERSION >= v"1.11.0-DEV.1432"
    const compat_get_bool_env = Base.get_bool_env
else
    function parse_bool_env(name::String, val::String = ENV[name]; throw::Bool=false)::Union{Nothing, Bool}
        xs
    end
end
"""
dest_signature = :(if VERSION >= v"1.11.0-DEV.1432" else function parse_bool_env(name::String, val::String = ENV[name]; throw::Bool=false)::Union{Nothing, Bool} end end)
dest_block = CodeBlock(dest_code, "dest_code.jl", dest_signature)
@test get_func_block(dest_block) == 5:5

end # module test_sugarcubes_get_func_block
