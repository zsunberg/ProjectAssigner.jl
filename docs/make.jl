using ProjectAssigner
using Documenter

DocMeta.setdocmeta!(ProjectAssigner, :DocTestSetup, :(using ProjectAssigner); recursive=true)

makedocs(;
    modules=[ProjectAssigner],
    authors="Zachary Sunberg <zachary.sunberg@colorado.edu> and contributors",
    repo="https://github.com/zsunberg/ProjectAssigner.jl/blob/{commit}{path}#{line}",
    sitename="ProjectAssigner.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://zsunberg.github.io/ProjectAssigner.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Usage" => "usage.md",
        "Data Format" => "data.md"
    ],
)

deploydocs(;
    repo="github.com/zsunberg/ProjectAssigner.jl",
    devbranch="main",
)
