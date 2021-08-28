module ProjectAssigner

using CSV
using DataFrames
using GLPK
using JuMP

mutable struct Group
    members::Set{String}
    skills::Dict{String,Float64}
    preferences::Vector{String}
end

struct IndexModel
    c::Matrix{Float64}            # c[i, j] is the cost for assigning group i to project j
    r::Matrix{Float64}            # r[k, i] is the amount of skill k that group i contributes
    s::Vector{Float64}            # s[i] is the size of group i
    minskills::Matrix{Float64}    # minskills[k, j] is the minimum number of people needed for skill k on project j
    minsizes::Vector{Float64}     # minimum sizes for each project
    maxsizes::Vector{Float64}     # maximum sizes for each project
    force::Vector{Pair{Int, Int}} # i => j means we are forcing group i to be assigned to project j
end

function IndexModel(groups::Vector{Group}, projects::DataFrame; force=[])
    skills = map(n->n[findfirst(':', n)+1:end], filter(n->startswith(n, "skill:"), names(projects)))
    skillinds = Dict(n=>k for (k, n) in enumerate(skills))
    pinds = Dict(p=>j for (j, p) in enumerate(projects[!, :name]))

    c = calculate_costs(groups, pinds)

    r = zeros(length(skillinds), length(groups))
    for (i, g) in enumerate(groups)
        for skill in keys(g.skills)
            r[skillinds[skill], i] = g.skills[skill]
        end
    end

    s = [length(g.members) for g in groups]

    minskills = zeros(length(skillinds), length(pinds))
    minsizes = zeros(nrow(projects))
    maxsizes = zeros(nrow(projects))
    for (j, row) in enumerate(Tables.rows(projects))
        minsizes[j] = row[:min]
        maxsizes[j] = row[:max]
        for skill in keys(skillinds)
            minskills[skillinds[skill], j] = row["skill:"*skill]
        end
    end

    # map from student name to group index
    ginds = Dict(Iterators.flatten((m=>i for m in groups[i].members) for i in 1:length(groups)))
    force_indices = map(force) do pair
        ginds[first(pair)] => pinds[last(pair)]
    end

    return IndexModel(c, r, s, minskills, minsizes, maxsizes, force_indices)
end

"""
    ProjectAssigner.match(;students, projects, [output], [force], [optimizer])

Match students to projects and return a dataframe with the assignments.

All arguments are keyword arguments, and the function is not exported, so it must be called with the module explicitly `ProjectAssigner.match(...)`.

# Example
```julia-repl
julia> ProjectAssigner.match(students="students.csv", projects="projects.csv")
```

# Keyword Arguments

- `students`: A `DataFrame` or csv filename `String` specifying information about the students. See the Data Format section of the documentation for more information.
- `projects`: A `DataFrame` or csv filename `String` specifying information about the projects. See the Data Format section of the documentation for more information.
- `output::String`: optional name for a csv file that the assignments will be written to.
- `force`: optional vector of student-project pairs to force matches for, e.g. `force=["Bob"=>"Airplane"]` will force student Bob to be assigned to the Airplane project.
- `optimizer::Function`: optimizer factory to use for the optimization, e.g. `optimizer=Gurobi.Optimizer` will use Gurobi instead of the default `GLPK`

!!! warning "Scaling Issues"
    Due to the exponential costs in the objective, the optimization problem may be poorly-scaled for large classes. This can result in the default GLPK optimizer producing poor results even though it thinks that it has solved the problem. More powerful commercial solvers such as [Gurobi](https://github.com/jump-dev/Gurobi.jl) can handle this much better.
"""
function match(;students, projects,
                output=nothing,
                force::AbstractVector{Pair{String,String}}=Pair{String,String}[],
                optimizer=GLPK.Optimizer
    )

    students = as_dataframe(students)
    projects = as_dataframe(projects)

    lint_input(students, projects)

    @info("Found $(nrow(students)) students and $(nrow(projects)) projects.", students, projects)

    groups = group(students)

    @debug(groups)

    assignments = match_groups(groups, projects, force=force, optimizer=optimizer)

    out = DataFrame(name=String[], project=String[], preference=Union{Int,Missing}[])
    for (i, g) in enumerate(groups)
        project = assignments[i]
        pref = something(findfirst(==(project), g.preferences), missing)
        for name in g.members
            push!(out, (name=name, project=assignments[i], preference=pref))
        end
    end
    @info("Assignments:", out)
    histogram = DataFrame(preference=[], number=Int[])
    for r in 1:maximum(skipmissing(out[!, :preference]))
        push!(histogram, (preference=r, number=sum(skipmissing(out[!, :preference].==r))))
    end
    push!(histogram, (preference=missing, number=sum(ismissing, out[!, :preference])))
    @info("Frequencies by preference rank:", histogram)

    if !isnothing(output)
        @info("Writing to $output.")
        CSV.write(output, out)
    end

    return out
end

function match_groups(groups, projects; force=[], optimizer=GLPK.Optimizer)
    m = IndexModel(groups, projects, force=force)

    if (maximum(m.c) + minimum(m.c)) == maximum(m.c) && optimizer == GLPK.Optimizer
        @error("""This problem is too large for GLPK.

               The cost coefficients have too large a range, and the solution will likely be suboptimal.

               Recommend switching to the Gurobi optimizer with
               ProjectAssigner.match(..., optimizer=Gurobi.Optimizer).""", extrema(m.c))
    end

    opt = create_jump_model(m)
    set_optimizer(opt, optimizer)
    optimize!(opt)

    if termination_status(opt) != MOI.OPTIMAL
        @error(termination_status(opt))
    end
    assignments = String[]
    x_opt = value.(opt[:x])
    for i in 1:length(groups)
        j = only(findall(x_opt[i,:] .> 0))
        push!(assignments, projects[j, :name])
    end
    return assignments
end

as_dataframe(fname::AbstractString) = DataFrame(CSV.File(fname))
as_dataframe(df::DataFrame) = df

function group(students::DataFrame)
    skills = String[]
    teammate_keys = String[]
    project_names = String[]
    for n in names(students)
        if startswith(n, "skill:")
            push!(skills, n[findfirst(':', n)+1:end])
        elseif startswith(n, "teammate_")
            push!(teammate_keys, n)
        elseif n != "name"
            push!(project_names, n)
        end
    end

    # extract partners
    partners = Dict{String, Set{String}}()
    for row in Tables.rows(students)
        partners[row[:name]] = Set(skipmissing(row[k] for k in teammate_keys))
    end

    # validate groups
    groups = Group[]
    groupmap = Dict{String, Int}()
    for (k,v) in partners
        if k in keys(groupmap)
            continue
        else
            candidate_group = union!(Set((k,)), v)
            valid = true
            for s in candidate_group
                s_candidate_group = union!(Set((s,)), partners[s])
                if s_candidate_group != candidate_group
                    valid = false
                end
            end
            if valid
                g = Group(candidate_group, Dict(skill=>0.0 for skill in skills), [])
                push!(groups, g)
                for s in candidate_group
                    groupmap[s] = length(groups)
                end
                if length(candidate_group) > 1
                    @info("Creating group $(collect(candidate_group))")
                end
            else
                @warn("""
                      Invalid teammate request for $k
                      """, Dict(s=>collect(partners[s]) for s in candidate_group))
                g = Group(Set((k,)), Dict(skill=>0.0 for skill in skills), [])
                push!(groups, g)
                groupmap[k] = length(groups)
            end
        end
    end

    # fill data in groups
    for row in Tables.rows(students)
        g = groups[groupmap[row[:name]]]
        for skill in skills
            g.skills[skill] += row["skill:"*skill]
        end
        prefs = sort(filter(p->!ismissing(row[p]),project_names), by=p->row[p])
        if !isempty(g.preferences) && prefs != g.preferences
            @warn("Preferences for $(collect(g.members)) don't match.", prefs, g.preferences)
        end
        if length(prefs) > length(g.preferences)
            g.preferences = prefs
        end
    end

    return groups
end

function create_jump_model(m::IndexModel)
    n_groups, n_projects = size(m.c)

    opt = Model()

    # x[i, j] = 1 indicates that group i is in project j
    @variable(opt, x[1:n_groups, 1:n_projects], Bin)

    @objective(opt, Min, sum(m.c.*x))

    for i in 1:n_groups
        @constraint(opt, sum(x[i, :]) == 1)
    end

    for j in 1:n_projects
        # skills
        pr = m.r*x[:, j]
        @constraint(opt, pr .>= m.minskills[:, j])
        # sizes
        ps = m.s'*x[:, j]
        @constraint(opt, m.minsizes[j] <= ps <= m.maxsizes[j])
    end

    for pair in m.force
        @constraint(opt, x[pair...] == 1)
    end

    return opt
end

function calculate_costs(groups, pinds)
    # number of students
    n = sum(length(g.members) for g in groups)

    # number of projects
    m = length(pinds)

    # constant for calculating costs
    logn = ceil(Int, log2(n))

    # c[i, j] is the cost of connecting group i to project j
    c = zeros(length(groups), m)

    for (i, g) in enumerate(groups)
        # fill in preferenced
        for (r, p) in enumerate(g.preferences)
            c[i, pinds[p]] = 2.0^(logn*(r-div(m,2)))*length(g.members)
        end

        # fill in unpreferenced
        if length(g.preferences) < length(pinds)
            r = length(g.preferences)+1
            missing_cost = 2.0^(logn*(r-div(m,2)))*length(g.members)
            row = view(c, i, :)
            row[row.==0.0] .= missing_cost
        end
    end

    return c
end

function lint_input(students, projects)
    # students table
    if !("name" in names(students))
        @error("Required column 'name' missing from students table.", names(students))
    end

    student_skills = Set{String}()
    teammate_keys = String[]
    project_names = Set{String}()
    for n in names(students)
        if startswith(n, "skill:")
            push!(student_skills, n[findfirst(':', n)+1:end])
        elseif startswith(n, "teammate_")
            push!(teammate_keys, n)
        elseif n != "name"
            push!(project_names, n)
        end
    end

    student_names = Set(students[!, :name])
    for r in Tables.rows(students)
        for t in teammate_keys
            if !ismissing(r[t]) && !(r[t] in student_names)
                @error("Teammate requrest not in list of student names.", request=r[t], requester=r[:name])
            end
        end
    end

    # projects table
    for c in ["name", "min", "max"]
        if !(c in names(projects))
            @error("Required column '$c' missing from projects table.", names(projects))
        end
    end

    for c in ["min", "max"]
        if !(eltype(projects[!, c]) <: Integer)
            @error("The type of column '$c' in the projects table was not Integer; instead it was $(eltype(projects[!,c])). Check for extraneous space or other characters.")
        end
    end

    project_skills = Set{String}()
    for n in names(projects)
        if startswith(n, "skill:")
            push!(project_skills, n[findfirst(':', n)+1:end])
        end
    end

    # combination
    if student_skills != project_skills
        @error("Project and student skill columns do not match!", project_skills, student_skills)
    end

    if Set(projects[!,:name]) != project_names
        @error("Project columns in students table and names in project table do not match.", projects[!,:name], project_names)
    end
end

end
