import re
from pathlib import Path

PROBLEMS = ["snake", "tetris"]
SOLVERS = ["lama-first", "seq-sat-lama-2011", "seq-opt-fdss-1"]
print("ProblemKind,Problem,Solver,Solved,Time,PlanLength,PlanCost,ExpandedNodes")

for kind in PROBLEMS:
    for dir in Path(kind).iterdir():
        data = (dir / "out.txt").read_text()
        solver = SOLVERS[int(dir.name[0]) - 1]
        problem = dir.name[2:-5]
        res = re.search(r"Solution found", data)
        time = re.findall(r"Planner time: (\d+\.\d+)s", data)[0]
        if res is not None:
            length = re.findall(r"Plan length: (\d+) step", data)[-1]
            cost = re.findall(r"Plan cost: (\d+)", data)[-1]
            expanded = re.findall(r"Expanded (\d+) state", data)[-1]
            solved = 1
        else:
            length = ""
            cost = ""
            solved = 0
            expanded = ""
        print(f"{kind},{problem},{solver},{solved},{time},{length},{cost},{expanded}")
