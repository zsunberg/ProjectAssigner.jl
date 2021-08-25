var documenterSearchIndex = {"docs":
[{"location":"usage/#Usage","page":"Usage","title":"Usage","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"ProjectAssigner has a single function, match for matching students to projects. In Julia, typical usage is as simple as:","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"import ProjectAssigner\nProjectAssigner.match(students=\"students.csv\", projects=\"projects.csv\", output=\"output.csv\")","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Similarly, in Python, typical usage looks like","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"from julia import ProjectAssigner\nProjectAssigner.match(students=\"students.csv\", projects=\"projects.csv\", output=\"output.csv\")","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Note that all arguments are keyword arguments. See the docstring below for information on the function options and the Data Format section for details about the input.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"ProjectAssigner.match","category":"page"},{"location":"usage/#ProjectAssigner.match","page":"Usage","title":"ProjectAssigner.match","text":"ProjectAssigner.match(;students, projects, [output], [force], [optimizer])\n\nwarning: Scaling Issues\nDue to the exponential costs in the objective, the optimization problem may be poorly-scaled for large classes. This can result in the default GLPK optimizer producing poor results even though it thinks that it has solved the problem. More powerful commercial solvers such as Gurobi can handle this much better.\n\n\n\n\n\n","category":"function"},{"location":"data/#Data-Format","page":"Data Format","title":"Data Format","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = ProjectAssigner","category":"page"},{"location":"#ProjectAssigner","page":"Home","title":"ProjectAssigner","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ProjectAssigner. More information about the approach can be found in our ASEE Paper.","category":"page"},{"location":"#Contents","page":"Home","title":"Contents","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"#Julia","page":"Home","title":"Julia","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"import Pkg; Pkg.add(url=\"https://github.com/zsunberg/ProjectAssigner.jl\")","category":"page"},{"location":"#Python","page":"Home","title":"Python","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"First, make sure to install pyjulia, then run the following:","category":"page"},{"location":"","page":"Home","title":"Home","text":"from julia import Pkg\nPkg.add(url=\"https://github.com/zsunberg/ProjectAssigner.jl\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"See Usage for information on how to use the package.","category":"page"}]
}
