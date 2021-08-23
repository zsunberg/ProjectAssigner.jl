module ProjectAssigner

using CSV
using DataFrames

mutable struct Group
    members::Set{String}
    skills::Dict{String,Float64}
    preferences::Vector{String}
end

function match(;students, projects,
                output=nothing)

    students = as_dataframe(students)
    projects = as_dataframe(projects)

    @info("Found $(nrow(students)) students and $(nrow(projects)) projects.", students, projects)

    groups = group(students)

    @debug(groups)

    assignments = match_groups(groups, projects)

    out = DataFrame()
    for (g, group) in enumerate(groups)
        project = assignments[g]
        pref = findfirst(project, group.preferences)
        for name in group.members
            push!(out, (name=name, project=assignments[g], preference=pref))
        end
    end

    if !isnothing(output)
        @info("Writing to $output.")
        CSV.write(output, out)
    end

    return out
end

struct IndexModel
    c::Matrix{Float64}            # c[i, j] is the cost for assigning group i to project j
    r::Matrix{Float64}            # r[k, i] is the amount of skill k that group i contributes
    s::Vector{Float64}            # s[i] is the size of group i
    minroles::Matrix{Float64}     # minroles[k, j] is the minimum number of people needed for role k on project j
    minsizes::Vector{Float64}     # minimum sizes for each project
    maxsizes::Vector{Float64}     # maximum sizes for each project
    force::Vector{Pair{Int, Int}} # i => j means we are forcing group i to be assigned to project j
end

function IndexModel(groups, projects; force=[])
    c = calculate_costs(students, projects, groups)
    r, pm, s = calculate_role_fractions(students, projects, groups)
    roles = collect_roles(projects)
    minroles = zeros(length(roles), length(projects))
    for (k, role) in enumerate(roles)
        for (j, p) in enumerate(projects)
            minroles[k, j] = get(p.minroles, role, 0.0)
        end
    end
    minsizes = [p.minsize for p in projects]
    maxsizes = [p.maxsize for p in projects]

    ginds = group_index_map(students, groups)
    pinds = Dict(p.id => j for (j,p) in enumerate(projects))
    force_indices = map(force) do pair
        ginds[first(pair)] => pinds[last(pair)]
    end

    return IndexModel(c, r, pm, s, minroles, minsizes, maxsizes, force_indices)
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



end
