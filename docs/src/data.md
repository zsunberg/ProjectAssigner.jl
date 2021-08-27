# Data Format

The data for the `student` and `projects` keyword arguments may be supplied as a [DataFrame](https://dataframes.juliadata.org/stable/) or a csv file. In either case the data requirements are identical and described below.

Example csv files may be found in the `test` directory of this repository.

## Students

Each row of this table corresponds to a student.

### Required Columns

- `name` (string): The student's name.

### Optional Columns

- **`skill:*` where `*` is a skill** (floating point number): Each column that begins exactly with `skill:` is interpreted as a skill contribution (see the `skill:` section in the Projects section below for more details.
- **`teammate_i` where `i` is an integer** (string): Any column that begins with `teammate_` is interpreted as a teammate request. This must match another `name` entry *exactly*. Teammates are guaranteed to be assigned together.
- **Project Preferences** (integer): Any column that does not begin with `teammate_` or `skill:` and is not `name` is interpreted as a project. Each entry in this column is an integer that encodes the student's preference for that project, with `1` indicating the most desired project. An empty entry is interpreted as a lower preference than all numbered entries. Each of these columns must match *exactly* with a `name` entry in the projects table.

## Projects

Each row of this table corresponds to a project.

### Required Columns

- `name` (string): The project's name.
- `min` (integer): The minimum number of students that can be assigned to the project.
- `max` (integer): The maximum number of students that can be assigned to the project.

### Optional Columns

- **`skill:*` where `*` is a skill** (floating point number): Each column that begins exactly with `skill:` is interpreted as a skill requirement. The set of students assigned to that project must have at least this total skill contribution among them. For example, if `skill:electronics` for a project is set to `1.5`, this requirement might be met with a single student with `skill:electronics` of `1.5` or three students with `skill:electronics` of `0.5`.
