#!/usr/bin/env  python3
# *-* encoding=utf8 *-*

import sys
import json
from trails import *

def put (tab, *args, **kwargs):
    print(f"\n{' ' * (tab * 2 - 1)}", *args, **kwargs, end="")

# ================================= OBJECTS ================================= #

def peanno_objects (n):
    """ Declare natural numbers: n0, n1, n2, ... """
    print()
    n += 1
    put(2, ";; Natural numbers")
    for i in range(n):
        put(2, f"n{i} - natural")

def element_objects ():
    """ Declare the seven elements. """
    print()
    put(2, ";; Elements")
    for e in Element:
        put(2, f"{e.lisp()} - element")

def quartz_objects():
    """ Declare quartz """
    print()
    put(2, ";; ======== Quartz ======== ;;")
    for q in quartz:
        put(2, f"{lispify(q.name)} - quartz")

def art_objects():
    """ Declare arts """
    print()
    put(2, ";; ======== Arts ======== ;;")
    for a in arts:
        put(2, f"{lispify(a.name)} - art")

def orbament_objects():
    """ Declare orbaments """
    print()
    put(2, ";; ======== Orbaments ======== ;;")
    for o in orbaments:
        put(2, f";;; >>> {o.name} <<< ;;;")
        put(2, f"{lispify(o.name)}-orbament - orbament")
        for slot in o.slots:
            put(2, f"{lispify(o.name)}-slot-{slot.num} - slot")
        for line in range(1, len(o.lines) + 1):
            put(2, f"{lispify(o.name)}-line-{line} - line")

def category_objects():
    """ Declare art categories """
    print()
    put(2, ";; ======== Categories ======== ;;")
    for c in categories:
        put(2, f"{lispify(c.name)} - category")

def objects (max_n : int):
    put(1, "(:objects")
    peanno_objects(max_n)
    element_objects()
    category_objects()
    quartz_objects()
    art_objects()
    orbament_objects()
    print(")")

# ================================== INIT =================================== #

def peanno_init (n):
    """ Define addition and comparison relationships for naturals. """
    print()
    n += 1
    put(2, ";; Addition")
    for lhs in range(n):
        for rhs in range(n):
            put(2, f"(addition n{lhs} n{rhs} n{min(lhs + rhs, n - 1)})")
    print()
    put(2, ";; Comparison")
    for lhs in range(n):
        for rhs in range(n):
            if lhs < rhs:
                put(2, f"(less-than n{lhs} n{rhs})")

def quartz_init():
    """ Set quartz power and asign them to a unique category. """
    print()
    put(2, ";; ======== Quartz ======== ;;")
    for q in quartz:
        put(2, f";;; >>> {q.name} <<< ;;;")
        put(2, f"(belongs {lispify(q.name)} {lispify(q.category.name)})")
        for e in Element:
            n = q.power[e] if e in q.power else 0
            put(2, f"(power {e.lisp()} {lispify(q.name)} n{n})")

def art_init():
    """ Set art requirements for each element. """
    print()
    put(2, ";; ======== Arts ======== ;;")
    for a in arts:
        put(2, f";;; >>> {a.name} <<< ;;;")
        for e in Element:
            n = a.reqs[e] if e in a.reqs else 0
            put(2, f"(requirement {e.lisp()} {lispify(a.name)} n{n})")

def orbament_init():
    """ Setup the orbament slots and how they are connected """
    print()
    put(2, ";; ======== Orbaments ======== ;;")
    for o in orbaments:
        put(2, f";;; >>> {o.name} <<< ;;;")
        for slot in o.slots:
            put(2, f"(contains-slot {lispify(o.name)}-orbament {lispify(o.name)}-slot-{slot.num})")
        for line in range(1, len(o.lines) + 1):
            put(2, f"(contains-line {lispify(o.name)}-orbament {lispify(o.name)}-line-{line})")
            for slot in o.lines[line - 1]:
                put(2, f"(connects {lispify(o.name)}-line-{line} {lispify(o.name)}-slot-{slot})")

def categories_init():
    """ Tell which categories are orbament-wide """
    print()
    put(2, ";; ======== Categories ======== ;;")
    for c in categories:
        if c.orbament_wide:
            put(2, f"(orbament-wide {lispify(c.name)})")

def init (max_n : int):
    put(1, f"(:init")
    put(2, f"(action-state)")
    put(2, f"(= (total-cost) 0)")
    peanno_init(max_n)
    quartz_init()
    art_init()
    orbament_init()
    categories_init()
    print()
    print()

# ================================= CONFIG ================================== #

def config (json : dict):
    init = json.get("init") or {}
    raw_inventory = init.get("inventory") or {}
    default_value = 0
    if isinstance(raw_inventory, int):
        default_value = raw_inventory
        raw_inventory = {}
    inventory = {search(quartz, key) : value
                 for key, value in raw_inventory.items()}
    config = {search(orbaments, o)
              : {search(orbaments, o).slots[int(s) - 1] : search(quartz, q)
                 for s, q in value.items()}
              for o, value in (init.get("configuration") or {}).items()}

    put(2, ";;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;;")
    put(2, ";; H E R E   G O E S   T H E   I N I T I A L   C O N F I G U R A T I O N  ;;")
    put(2, ";;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;;")
    print()
    put(2, ";;; ~ Quartz count in inventory ~")

    for q in quartz:
        n = inventory[q] if q in inventory else default_value
        put(2, f"(inventory-count {lispify(q.name)} n{n})")
    print()

    put(2, ";;; ~ Initial configuration ~")
    for o in orbaments:
        slots = config.get(o) or {}
        put(2, f";; {o.name}")
        power = {l + 1 : {e : 0 for e in Element} for l in range(len(o.lines))}
        for slot, q in slots.items():
            put(2, f"(filled {lispify(o.name)}-slot-{slot.num})")
            put(2, f"(contains-quartz {lispify(o.name)}-slot-{slot.num} {lispify(q.name)})")
            lines = {i + 1 : line
                     for i, line in enumerate(o.lines) if slot.num in line}
            if q.category.orbament_wide:
                put(2, f"(restricted {lispify(o.name)}-orbament {lispify(q.category.name)})")
            else:
                slots_to_restrict = \
                        set((x for x in line) for line in lines.values())
                for slot in slots_to_restrict:
                    put(2, f"(restricted {lispify(o.name)}-slot-{slot} {lispify(q.category.name)})")

            # increment elemental value in every line
            for line in lines.keys():
                for e in Element:
                    power[line][e] += q.power.get(e) or 0
        for l, x in power.items():
            for e, v in x.items():
                put(2, f"(value {e.lisp()} {lispify(o.name)}-line-{l} n{v})")

    print(")")

# ================================== GOAL =================================== #

def goal (json : dict):
    put(1, ";;;            ~ Goal ~            ;;;")
    print()
    put(1, "(:goal")
    put(2, "(and")
    put(3, "(action-state)")
    goal = json.get("goal") or []
    for subgoal in goal:
        name = subgoal.get("orbament")
        name = name or search(orbaments, name)
        line = subgoal.get("line")
        for art in map(lambda x : search(arts, x), subgoal["arts"]):
            if name is None:
                put(3, f"(any-active {lispify(art.name)})")
            elif line is None:
                put(3, f"(orbament-active {lispify(name.name)}-orbament {lispify(art.name)})")
            else:
                put(3, f"(line-active {lispify(name.name)}-line-{line} {lispify(art.name)})")

    print("))")


# ================================== HELP =================================== #

def max_number ():
    """ Estimate the maximum number of power an element can have. """
    # To obtain the maximum number, for each element:
    best = 0
    for e in Element:
        # Obtain all the quartzs that yield that element
        qs = list(sorted(filter(lambda q : e in q.power, quartz),
                         key=lambda q : q.power[e]))
        # Greedy algorithm, assume infinite lines.
        cat = set()
        res = []
        while len(res) < MAX_SLOTS and qs:
            q = qs.pop()
            if not q.category.orbament_wide or q.category not in cat:
                cat.add(q.category)
                res.append(q)
        best = max(sum(map(lambda q : q.power[e], res)), best)
    return best

# ================================== MAIN =================================== #

# TODO: Fix comment formats: ;;;; > ;;; > ;; > ;

if __name__ == "__main__":
    if len(sys.argv) != 2 or "-h" in sys.argv or "--help" in sys.argv:
        print(f"USAGE: {sys.argv[0]} problem.json > problem.pddl")
        print()
        print(f"This file is used to generate the problem file from a JSON")
        print(f"file. Refer to problems/README.md to see more information")
        print(f"about the JSON schema.")
        exit()

    with open(sys.argv[1], "r") as fp:
        data = json.load(fp)

    print(";;;; vim: ft=scheme")
    print(f";;;; ~ Problem -- {data["name"]} ~")
    print(";;;;", end="")
    length = 4
    for word in data["description"].split():
        if len(word) + length + 1 > 79:
            length = 4
            print("\n;;;;", end="")
        length += 1 + len(word)
        print(" " + word, end = "")
    print()
    print(";;;;")
    simplify_domain(data)
    print(f";;;; Problem file generated from `{sys.argv[1]}'.")
    print()

    max_n = max_number()

    print("(define (problem orbament-settings-layout)")
    print("  (:domain orbament-settings)")
    objects(max_n)
    init(max_n)
    config(data)
    goal(data)
    put(1, "(:metric minimize (total-cost))")
    print(")")
    print()
