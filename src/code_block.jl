# module SugarCubes

using .JS: @K_str
using DeepDiffs: DeepDiffs

function to_signature(expr::Expr, depth::Int = 1, layers::Vector{SigLayer} = SigLayer[])::Signature
    if depth == 1
        remove_linenums_in_macrocall!(expr)
    end
    if expr.head === :module
        push!(layers, (depth, K"module", expr))
        next = expr.args[end].args[1]
        to_signature(next, depth + 1, layers)
    elseif expr.head === :if
        if isempty(expr.args[2].args)
            if expr.args[3].head === :elseif
                kind = K"elseif"
                next = expr.args[3].args[2].args[1]
            else
                kind = K"else"
                next = expr.args[3].args[1]
            end
        else
            kind = K"if"
            next = expr.args[2].args[1]
        end
        push!(layers, (depth, kind, expr))
        to_signature(next, depth + 1, layers)
    elseif expr.head === :function
        push!(layers, (depth, K"function", expr))
        Signature(layers)
    elseif expr.head === :macro
        push!(layers, (depth, K"macro", expr))
        Signature(layers)
    else
        push!(layers, (depth, K"error", expr))
        Signature(layers)
    end
end

const LF = "\n"

function find_start_line(code::String, range::UnitRange{Int})::Int
    lines = split(code, LF)[range]
    for idx in 1:length(lines)
        sig = string(join(lines[1:idx], LF), " end")
        expr = JS.fl_parseall(Expr, sig)
        if expr.args[end].head !== :incomplete
            return range.start + idx
        end
    end
    return range.stop
end

function matched_lines(code_block::CodeBlock, sub::Expr, sig_func::Expr)::Union{Nothing, UnitRange{Int}}
    sub_args1 = sub.args[1]
    sig_args1 = sig_func.args[1]
    if sub_args1 isa Expr && sig_args1 isa Expr &&
        ((sub_args1.head === :call && sig_args1.head === :call) ||
         (sub_args1.head === :(::) && sig_args1.head === :(::)))
        remove_linenums_in_macrocall!(sub_args1)
        if sub_args1 == sig_args1
            first_line = sub.args[2].args[1].line
            second_line = sub.args[2].args[2].line
            if isone(second_line - first_line)
                start_line = second_line
            else
                start_line = find_start_line(code_block.code, first_line:second_line)
            end
            end_line = sub.args[2].args[end-1].line
            return start_line:end_line
        end
    end
    return nothing
end

expr_cache::Dict{UInt64, Expr} = Dict{Int64, Expr}()
function get_parsed_expr(code_block::CodeBlock)::Expr
    cache_key::UInt64 = hash(code_block.code)
    if haskey(expr_cache, cache_key)
        expr_cache[cache_key]
    else
        ex::Expr = JS.fl_parseall(Expr, code_block.code; filename = code_block.filename)
        expr_cache[cache_key] = ex
        ex
    end
end

function get_func_block(code_block::CodeBlock, code_expr::Expr, layers::Vector{SigLayer}, depth::Int)::Union{Nothing, UnitRange{Int}}
    length(layers) < depth && return nothing
    (depth, kind, sig_expr) = layers[depth]
    if kind === K"function" && code_expr.head === :function
        matched = matched_lines(code_block, code_expr, sig_expr)
        matched isa UnitRange{Int} && return matched
    elseif kind === K"macro"
        if code_expr.head === :block
            for sub_macro in code_expr.args
                if sub_macro isa Expr
                    if sub_macro.head === :macro
                        matched = matched_lines(code_block, sub_macro, sig_expr)
                        matched isa UnitRange{Int} && return matched
                    elseif sub_macro.head === :macrocall
                        for sub_block in sub_macro.args
                            if sub_block isa Expr && sub_block.head === :macro
                                matched = matched_lines(code_block, sub_block, sig_expr)
                                matched isa UnitRange{Int} && return matched
                            end
                        end # for sub_block
                    end # if
                end # if
            end # for sub_macro
        elseif code_expr.head === :macro
            matched = matched_lines(code_block, code_expr, sig_expr)
            matched isa UnitRange{Int} && return matched
        end # if
    else
        for sub in code_expr.args
            sub isa Expr || continue
            if kind === K"function" || kind === K"macro"
                matched = get_func_block(code_block, sub, layers, depth)
                matched isa UnitRange{Int} && return matched
            elseif kind === K"if" && sub.head === :if
                sub_block = sub.args[2]
                if sub_block isa Expr && sub_block.head === :block
                    matched = get_func_block(code_block, sub_block, layers, depth + 1)
                    matched isa UnitRange{Int} && return matched
                end
            elseif kind === K"elseif"
                if sub.head === :if
                    for sub_elseif in sub.args
                        if sub_elseif isa Expr && sub_elseif.head === :elseif
                            for sub_block in  sub_elseif.args[end].args
                                if sub_block isa Expr
                                    matched = get_func_block(code_block, sub_block, layers, depth + 1)
                                    matched isa UnitRange{Int} && return matched
                                end
                            end # for sub_block
                        end # if
                    end # for sub_elseif
                end # if
            elseif kind === K"else"
                sub_block = sub.args[end]
                if sub_block isa Expr && sub_block.head === :block
                    matched = get_func_block(code_block, sub_block, layers, depth + 1)
                    matched isa UnitRange{Int} && return matched
                end
            elseif kind === K"module"
                if sub.head === :macrocall
                    for sub_module in sub.args
                        if sub_module isa Expr && sub_module.head === :module
                            sub_block = sub_module.args[end]
                            if sub_block isa Expr && sub_block.head === :block
                                matched = get_func_block(code_block, sub_block, layers, depth + 1)
                                matched isa UnitRange{Int} && return matched
                            end
                        end # if
                    end # for sub_module
                elseif sub.head === :module
                    for sub_block in sub.args
                        if sub_block isa Expr && sub_block.head === :block
                            matched = get_func_block(code_block, sub_block, layers, depth + 1)
                            matched isa UnitRange{Int} && return matched
                        end
                    end # for sub_block
                end # if
            end # if
        end # for sub
    end # if
    return nothing
end

function get_func_block(code_block::CodeBlock, signature::Signature)::Union{Nothing, UnitRange{Int}}
    parsed_expr::Expr = get_parsed_expr(code_block)
    get_func_block(code_block, parsed_expr, signature.layers, 1)
end

function get_func_block(code_block::CodeBlock)::Union{Nothing, UnitRange{Int}}
    get_func_block(code_block, code_block.signature)
end

function get_lines(code::String, range::UnitRange{Int}, skip_lines::Vector{Int})::String
    lines = split(code, LF)[range]
    if isempty(skip_lines)
        join(lines, LF)
    else
        len = length(lines)
        skip_set = map(skip_lines) do num
            if signbit(num)
                len + num + 1
            else
                num
            end
        end
        setdiff_lines = lines[setdiff(1:len, skip_set)]
        join(setdiff_lines, LF)
    end
end

"""
    code_block_with(; filepath::String, signature::Expr)::CodeBlock
"""
function code_block_with(; filepath::String, signature::Expr)::CodeBlock
    code = read(filepath, String)
    filename = basename(filepath)
    CodeBlock(code, filename, signature)
end

"""
    has_diff(src_block::CodeBlock,
             dest_block::CodeBlock ;
             show_diff::Bool = true,
             skip_lines::@NamedTuple{src::Vector{Int}, dest::Vector{Int}} = (src = Int[], dest = Int[]))::Bool
"""
function has_diff(src_block::CodeBlock,
                 dest_block::CodeBlock ;
                 show_diff::Bool = true,
                 skip_lines::@NamedTuple{src::Vector{Int}, dest::Vector{Int}} = (src = Int[], dest = Int[]))::Bool
    src_range = get_func_block(src_block)
    dest_range = get_func_block(dest_block)
    if src_range === nothing || dest_range === nothing
        throw(CodeBlockError(string("src: ", src_range, ", dest: ", dest_range)))
        return false
    else
        src_code = get_lines(src_block.code, src_range, skip_lines.src)
        dest_code = get_lines(dest_block.code, dest_range, skip_lines.dest)
        result = src_code != dest_code
        if result && show_diff
            println(stdout, "\n", DeepDiffs.deepdiff(src_code, dest_code))
        end
        return result
    end
end

# module SugarCubes
