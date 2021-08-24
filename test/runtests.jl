using ProjectAssigner: match
using Test
using DataFrames

@testset "ProjectAssigner.jl" begin
    @testset "Basic match" begin
        m = match(students="students.csv", projects="projects.csv")

        d = Dict(r[:name]=>r[:project] for r in Tables.rows(m))
        @test d["Alice"] == "Airplane"
        @test d["Bob"] == "Airplane"
        @test d["Charlie"] == "Cubesat"
        @test d["Dale"] == "Cubesat"
    end

    @testset "Force" begin
        m = match(students="students.csv", projects="projects.csv", force=["Charlie"=>"Cubesat"])
        d = Dict(r[:name]=>r[:project] for r in Tables.rows(m))
        @test d["Alice"] == d["Bob"]
        @test d["Charlie"] == "Cubesat"

        m = match(students="students.csv", projects="projects.csv", force=["Charlie"=>"Airplane"])
        d = Dict(r[:name]=>r[:project] for r in Tables.rows(m))
        @test d["Alice"] == d["Bob"]
        @test d["Charlie"] == "Airplane"
    end
end
