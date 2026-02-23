# module SugarCubes

struct CodeBlock
    filepath::String
    signature::Expr
    function CodeBlock(filepath::String, signature::Expr)
        Base.remove_linenums!(signature)
        new(filepath, signature)
    end
end

macro code_block(filepath::Symbol, sig::Expr)
    sig_node = QuoteNode(sig)
    quote
        CodeBlock($(esc(filepath)), $sig_node)
    end
end # macro code_block

# module SugarCubes
