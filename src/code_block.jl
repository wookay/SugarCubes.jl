# module SugarCubes

using JuliaSyntax: JuliaSyntax as JS
using .JS: SyntaxTree, parseall, parsestmt, @K_str

struct CodeBlock
    code::String
    filename::String
    signature::Expr
    function CodeBlock(code::String, filename::String, signature::Expr)
        Base.remove_linenums!(signature)
        new(code, filename, signature)
    end
end

function code_block_with(; filepath::String, signature::Expr)::CodeBlock
    code = read(filepath, String)
    filename = basename(filepath)
    CodeBlock(code, filename, signature)
end

function get_func_block(code_block::CodeBlock)::Union{Nothing, UnitRange{Int}}
    expr = JS.fl_parseall(Expr, code_block.code; filename = code_block.filename)
    for sub in expr.args
        if sub isa Expr && sub.head === :function && sub.args[1] == code_block.signature.args[1]
            start_line = sub.args[2].args[2].line
            end_line = sub.args[2].args[end-1].line
            return start_line:end_line
        end
    end
    return nothing
end

struct CodeBlockError <: Exception
    msg::String
end

const LF = "\n"

function get_lines(code::String, range::UnitRange{Int})::String
    join(split(code, LF)[range], LF)
end

function has_diff(src_block::CodeBlock, dest_block::CodeBlock)::Bool
    src_range = get_func_block(src_block)
    dest_range = get_func_block(dest_block)
    if src_range === nothing || dest_range === nothing
        throw(CodeBlockError(string("src: ", src_range, " dest: ", dest_range)))
        return false
    else
        src_code = get_lines(src_block.code, src_range)
        dest_code = get_lines(dest_block.code, dest_range)
        return src_code != dest_code
    end
end

# module SugarCubes
