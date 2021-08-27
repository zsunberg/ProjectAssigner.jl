# note - you must have pyjulia (https://github.com/JuliaPy/pyjulia) installed, and run the following once:
# 
# from julia import Pkg
# Pkg.add(url="https://github.com/zsunberg/ProjectAssigner.jl")

from julia import ProjectAssigner
ProjectAssigner.match(students="students.csv", projects="projects.csv", output="output.csv")
