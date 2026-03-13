# module SugarCubes

using JuliaSyntax: JuliaSyntax as JS
using .JS: Kind, @K_str

# from julia/base/expr.jl  remove_linenums!(@nospecialize ex)
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

struct Signature
    kind::Kind
    func::Expr
end

function to_signature(sig::Expr)::Signature
    remove_linenums_in_macrocall!(sig)
    if sig.head === :function
        Signature(K"function", sig)
    elseif sig.head === :if
        if isempty(sig.args[2].args)
            if sig.args[3].head === :elseif
                Signature(K"elseif", sig.args[3].args[2].args[1])
            else
                Signature(K"else", sig.args[3].args[1])
            end
        else
            Signature(K"if", sig.args[2].args[1])
        end
    elseif sig.head === :module
        Signature(K"module", sig.args[4].args[1])
    else
        Signature(K"error", Expr(:error))
    end
end

# export CodeBlock
struct CodeBlock
    code::String
    filename::String
    signature::Signature
    function CodeBlock(code::String, filename::String, sig::Expr)
        new(code, filename, to_signature(sig))
    end
end

# export code_block_with
function code_block_with(; filepath::String, signature::Expr)::CodeBlock
    code = read(filepath, String)
    filename = basename(filepath)
    CodeBlock(code, filename, signature)
end

function matched_lines(sub::Expr, sig_func::Expr)::Union{Nothing, UnitRange{Int}}
    sub_args1 = sub.args[1]
    if sub_args1 isa Expr && sub_args1.head === :call && sub_args1.args[1] === sig_func.args[1].args[1]
        remove_linenums_in_macrocall!(sub_args1)
        if sub_args1 == sig_func.args[1]
            start_line = sub.args[2].args[2].line
            end_line = sub.args[2].args[end-1].line
            return start_line:end_line
        end
    end
    return nothing
end

function get_func_block(code_block::CodeBlock)::Union{Nothing, UnitRange{Int}}
    expr = JS.fl_parseall(Expr, code_block.code; filename = code_block.filename)
    for sub in expr.args
        if code_block.signature.kind === K"function" && sub isa Expr && sub.head === :function
            matched = matched_lines(sub, code_block.signature.func)
            matched isa UnitRange{Int} && return matched
        elseif code_block.signature.kind === K"if" && sub isa Expr && sub.head === :if
            if sub.args[2].head === :block
                for sub_func in sub.args[2].args
                    if sub_func isa Expr && sub_func.head === :function
                        matched = matched_lines(sub_func, code_block.signature.func)
                        matched isa UnitRange{Int} && return matched
                    end
                end # for sub_func
            end # if
        elseif code_block.signature.kind === K"elseif" && sub isa Expr && sub.head === :if
            for sub_arg in sub.args
                if sub_arg.head === :elseif
                    for sub_else in sub_arg.args
                        if sub_else.head === :block
                            for sub_func in sub_else.args
                                if sub_func isa Expr && sub_func.head === :function
                                    matched = matched_lines(sub_func, code_block.signature.func)
                                    matched isa UnitRange{Int} && return matched
                                end
                            end # for sub_func
                        elseif sub_else.head === :elseif
                            for sub_func in sub_else.args[2].args
                                if sub_func isa Expr && sub_func.head === :function
                                    matched = matched_lines(sub_func, code_block.signature.func)
                                    matched isa UnitRange{Int} && return matched
                                end
                            end # for sub_func
                        end # if
                    end # for sub_else
                end # if
            end # for sub_arg
        elseif code_block.signature.kind === K"else" && sub isa Expr && sub.head === :if
            for sub_else in sub.args[3:end]
                if sub_else.head === :block
                    for sub_func in sub_else.args
                        if sub_func isa Expr && sub_func.head === :function
                            matched = matched_lines(sub_func, code_block.signature.func)
                            matched isa UnitRange{Int} && return matched
                        end
                    end # for sub_func
                end # if
            end # for sub_else
        elseif code_block.signature.kind === K"module" && sub isa Expr
            for sub_arg in sub.args
                if sub_arg isa Expr
                    if sub_arg.head === :module
                        for sub_func in sub_arg.args[3].args
                            if sub_func isa Expr && sub_func.head === :function
                                matched = matched_lines(sub_func, code_block.signature.func)
                                matched isa UnitRange{Int} && return matched
                            end
                        end # for sub_func
                    elseif sub_arg.head === :block
                        for sub_func in sub_arg.args
                            if sub_func isa Expr && sub_func.head === :function
                                matched = matched_lines(sub_func, code_block.signature.func)
                                matched isa UnitRange{Int} && return matched
                            end
                        end # for sub_func
                    end # if
                end # if
            end # for sub_arg
        end # if
    end # for sub
    return nothing
end

struct CodeBlockError <: Exception
    msg::String
end

const LF = "\n"

function get_lines(code::String, range::UnitRange{Int})::String
    join(split(code, LF)[range], LF)
end

# export has_diff
function has_diff(src_block::CodeBlock, dest_block::CodeBlock)::Bool
    src_range = get_func_block(src_block)
    dest_range = get_func_block(dest_block)
    if src_range === nothing || dest_range === nothing
        throw(CodeBlockError(string("src: ", src_range, ", dest: ", dest_range)))
        return false
    else
        src_code = get_lines(src_block.code, src_range)
        dest_code = get_lines(dest_block.code, dest_range)
        return src_code != dest_code
    end
end

# module SugarCubes
