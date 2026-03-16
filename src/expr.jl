# module SugarCubes

# from julia/base/expr.jl  remove_linenums!(@nospecialize ex)
"""
    remove_linenums_in_macrocall!(ex::Expr)
"""
function remove_linenums_in_macrocall!(ex::Expr)
    if ex.head === :block || ex.head === :quote
        # remove line number expressions from metadata (not argument literal or inert) position
        filter!(ex.args) do x
            isa(x, Expr) && x.head === :line && return false
            isa(x, LineNumberNode) && return false
            return true
        end
    ### macrocall case
    elseif ex.head === :macrocall
        ex.args = map(ex.args) do subex
            isa(subex, LineNumberNode) ? nothing : subex
        end
    end
    for subex in ex.args
        subex isa Expr && remove_linenums_in_macrocall!(subex)
    end
    return ex
end

# module SugarCubes
