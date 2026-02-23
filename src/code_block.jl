# module SugarCubes

struct CodeBlock
    filepath::String
    signature::Expr
end

macro code_block(filepath::Symbol, sig::Expr)
    Base.remove_linenums!(sig)
    sig_node = QuoteNode(sig)
    quote
        CodeBlock($(esc(filepath)), $sig_node)
    end
end # macro code_block

# module SugarCubes
