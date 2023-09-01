using ProjectAssigner: match
using Test
using DataFrames

@testset "ProjectAssigner.jl" begin
    @testset "Basic match" begin
        m = match(students="students.csv", projects="projects.csv", output="out.csv")

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

    @testset "Equally-Ranked Projects" begin
        m = match(students="students_multiple.csv", projects="projects.csv", output="out.csv")

        d = Dict(r[:name]=>r[:project] for r in Tables.rows(m))
        @test d["Alice"] == "Airplane"
        @test d["Bob"] == "Airplane"
        @test d["Charlie"] == "Cubesat"
        @test d["Dale"] == "Cubesat"
    end

    @testset "Errors" begin
        students = DataFrame()
        @test_throws ArgumentError m = match(students=students, projects="projects.csv")

        projects = DataFrame()
        @test_throws ArgumentError m = match(students="students.csv", projects=projects)

        projects = DataFrame("name"=>[], "min"=>String[], "max"=>String[], "skill:test"=>String[])
        @test_throws Any m = match(students="students.csv", projects=projects)
    end
end
