using ProjectAssigner: match
using Test

@testset "ProjectAssigner.jl" begin
    match(students="students.csv", projects="projects.csv")
end
