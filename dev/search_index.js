var documenterSearchIndex = {"docs":
[{"location":"usage/#Usage","page":"Usage","title":"Usage","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"ProjectAssigner has a single function, match for matching students to projects. In Julia, typical usage is as simple as:","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"import ProjectAssigner\nProjectAssigner.match(students=\"students.csv\", projects=\"projects.csv\", output=\"output.csv\")","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Similarly, in Python, typical usage looks like","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"from julia import ProjectAssigner\nProjectAssigner.match(students=\"students.csv\", projects=\"projects.csv\", output=\"output.csv\")","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Note that all arguments are keyword arguments. See the docstring below for information on the function options and the Data Format section for details about the input.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"ProjectAssigner.match","category":"page"},{"location":"usage/#ProjectAssigner.match","page":"Usage","title":"ProjectAssigner.match","text":"ProjectAssigner.match(;students, projects, [output], [force], [optimizer])\n\nMatch students to projects and return a dataframe with the assignments.\n\nAll arguments are keyword arguments, and the function is not exported, so it must be called with the module explicitly ProjectAssigner.match(...).\n\nExample\n\njulia> ProjectAssigner.match(students=\"students.csv\", projects=\"projects.csv\")\n\nKeyword Arguments\n\nstudents: A DataFrame or csv filename String specifying information about the students. See the Data Format section of the documentation for more information.\nprojects: A DataFrame or csv filename String specifying information about the projects. See the Data Format section of the documentation for more information.\noutput::String: optional name for a csv file that the assignments will be written to.\nforce: optional vector of student-project pairs to force matches for, e.g. force=[\"Bob\"=>\"Airplane\"] will force student Bob to be assigned to the Airplane project.\noptimizer::Function: optimizer factory to use for the optimization, e.g. optimizer=Gurobi.Optimizer will use Gurobi instead of the default GLPK\n\nwarning: Scaling Issues\nDue to the exponential costs in the objective, the optimization problem may be poorly-scaled for large classes. This can result in the default GLPK optimizer producing poor results even though it thinks that it has solved the problem. More powerful commercial solvers such as Gurobi (used with keyword argument optimizer=Gurobi.Optimizer) can handle this much better.\n\n\n\n\n\n","category":"function"},{"location":"data/#Data-Format","page":"Data Format","title":"Data Format","text":"","category":"section"},{"location":"data/","page":"Data Format","title":"Data Format","text":"The data for the student and projects keyword arguments may be supplied as a DataFrame or a csv file. In either case the data requirements are identical and described below.","category":"page"},{"location":"data/","page":"Data Format","title":"Data Format","text":"Example csv files may be found in the test directory of this repository.","category":"page"},{"location":"data/#Students","page":"Data Format","title":"Students","text":"","category":"section"},{"location":"data/","page":"Data Format","title":"Data Format","text":"Each row of this table corresponds to a student.","category":"page"},{"location":"data/#Required-Columns","page":"Data Format","title":"Required Columns","text":"","category":"section"},{"location":"data/","page":"Data Format","title":"Data Format","text":"name (string): The student's name.","category":"page"},{"location":"data/#Optional-Columns","page":"Data Format","title":"Optional Columns","text":"","category":"section"},{"location":"data/","page":"Data Format","title":"Data Format","text":"skill:* where * is a skill (floating point number): Each column that begins exactly with skill: is interpreted as a skill contribution (see the skill: section in the Projects section below for more details.\nteammate_i where i is an integer (string): Any column that begins with teammate_ is interpreted as a teammate request. This must match another name entry exactly. Teammates are guaranteed to be assigned together.\nProject Preferences (integer): Any column that does not begin with teammate_ or skill: and is not name is interpreted as a project. Each entry in this column is an integer that encodes the student's preference for that project, with 1 indicating the most desired project. An empty entry is interpreted as a lower preference than all numbered entries. Each of these columns must match exactly with a name entry in the projects table.","category":"page"},{"location":"data/#Projects","page":"Data Format","title":"Projects","text":"","category":"section"},{"location":"data/","page":"Data Format","title":"Data Format","text":"Each row of this table corresponds to a project.","category":"page"},{"location":"data/#Required-Columns-2","page":"Data Format","title":"Required Columns","text":"","category":"section"},{"location":"data/","page":"Data Format","title":"Data Format","text":"name (string): The project's name.\nmin (integer): The minimum number of students that can be assigned to the project.\nmax (integer): The maximum number of students that can be assigned to the project.","category":"page"},{"location":"data/#Optional-Columns-2","page":"Data Format","title":"Optional Columns","text":"","category":"section"},{"location":"data/","page":"Data Format","title":"Data Format","text":"skill:* where * is a skill (floating point number): Each column that begins exactly with skill: is interpreted as a skill requirement. The set of students assigned to that project must have at least this total skill contribution among them. For example, if skill:electronics for a project is set to 1.5, this requirement might be met with a single student with skill:electronics of 1.5 or three students with skill:electronics of 0.5.","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = ProjectAssigner","category":"page"},{"location":"#ProjectAssigner","page":"Home","title":"ProjectAssigner","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ProjectAssigner. More information about the approach can be found in our ASEE Paper.","category":"page"},{"location":"","page":"Home","title":"Home","text":"See the examples directory for example scripts in julia and python.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Pages=[\"index.md\", \"usage.md\", \"data.md\"]","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"#Julia","page":"Home","title":"Julia","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"import Pkg; Pkg.add(url=\"https://github.com/zsunberg/ProjectAssigner.jl\")","category":"page"},{"location":"#Python","page":"Home","title":"Python","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"First, make sure to install pyjulia, then run the following:","category":"page"},{"location":"","page":"Home","title":"Home","text":"from julia import Pkg\nPkg.add(url=\"https://github.com/zsunberg/ProjectAssigner.jl\")","category":"page"}]
}
