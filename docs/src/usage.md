# Usage

ProjectAssigner has a single function, `match` for matching students to projects. In Julia, typical usage is as simple as:

```julia
import ProjectAssigner
ProjectAssigner.match(students="students.csv", projects="projects.csv", output="output.csv")
```

Similarly, in Python, typical usage looks like

```python
from julia import ProjectAssigner
ProjectAssigner.match(students="students.csv", projects="projects.csv", output="output.csv")
```

Note that all arguments are keyword arguments. See the docstring below for information on the function options and the [Data Format](@ref) section for details about the input.

```@docs
ProjectAssigner.match
```
