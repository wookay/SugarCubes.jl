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
    signature::Signature
end
```
"""
struct CodeBlock
    code::String
    filename::String
    signature::Signature
    function CodeBlock(code::String, filename::String, expr::Expr)
        new(code, filename, to_signature(expr))
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
