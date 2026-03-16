using SugarCubes
using Documenter

makedocs(
    build = joinpath(@__DIR__, "local" in ARGS ? "build_local" : "build"),
    modules = [SugarCubes],
    clean = false,
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        assets = ["assets/custom.css"],
    ),
    sitename = "SugarCubes.jl 🧊",
    authors = "WooKyoung Noh",
    pages = Any[
        "Home" => "index.md",
        "types" => "types.md",
        "functions" => "functions.md",
    ],
)
