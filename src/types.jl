# module SugarCubes

using .JS: Kind

"""
```
const SigLayer = Tuple{Int, JuliaSyntax.Kind, Expr}
```
"""
const SigLayer = Tuple{Int, Kind, Expr}

"""
```
struct Signature
    layers::Vector{SigLayer}
end
```
"""
struct Signature
    layers::Vector{SigLayer}
end

# export CodeBlock
"""
```
struct CodeBlock
    code::String
    filename::String
    signature::Union{Nothing, Signature}
end
```
"""
struct CodeBlock
    code::String
    filename::String
    signature::Union{Nothing, Signature}
    function CodeBlock(code::String, filename::String, expr::Union{Nothing, Expr})
        signature = expr === nothing ? nothing : to_signature(expr)
        new(code, filename, signature)
    end
end

"""
```
struct CodeBlockError <: Exception
    msg::String
end
```
"""
struct CodeBlockError <: Exception
    msg::String
end

# module SugarCubes
