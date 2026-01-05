#!/usr/bin/env  python3
# *-* encoding=utf8 *-*

import sys
import enum

MAX_SLOTS = 6

def lispify (name: str) -> str:
    accents = [("á", "a"), ("é", "e"), ("í", "i"), ("ó", "o"), ("ú", "u")]
    name = name.lower().replace(" ", "-")
    for char, replace in accents:
        name = name.replace(char, replace)
    return name

class Element (enum.Enum):
    Earth = 1
    Water = 2
    Fire = 3
    Wind = 4
    Time = 5
    Space = 6
    Mirage = 7

    def __repr__ (self):
        return colour(self, str(self))

    def lisp(self):
        return lispify(self.name)

    def spanish (self):
        match self:
            case Element.Earth:  item = "Tierra"
            case Element.Water:  item = "Agua"
            case Element.Fire:   item = "Fuego"
            case Element.Wind:   item = "Viento"
            case Element.Time:   item = "Tiempo"
            case Element.Space:  item = "Espacio"
            case Element.Mirage: item = "Espejismo"
        return item

    def __str__ (self):
        return self.spanish()

def colour(element : Element | None, item : str) -> str:
    match element:
        case None: return item
        case Element.Earth:  return f"\033[33m{item}\033[0m"
        case Element.Water:  return f"\033[35m{item}\033[0m"
        case Element.Fire:   return f"\033[31m{item}\033[0m"
        case Element.Wind:   return f"\033[32m{item}\033[0m"
        case Element.Time:   return f"\033[37m{item}\033[0m"
        case Element.Space:  return f"\033[93m{item}\033[0m"
        case Element.Mirage: return f"\033[37m{item}\033[0m"

type Power = dict[Element, int]

class Slot:
    def __init__ (self, num : int, restriction : Element | None = None):
        self.num = num
        self.restriction = restriction

    def __repr__ (self):
        return colour(self.restriction, f"[#{self.num}]")

class Orbament:
    def __init__ (self, name : str, slots : list[Slot], lines : list[list[int]]):
        self.name = name
        self.slots = slots
        self.lines = lines

    def __repr__ (self):
        return f"{self.name} ({' '.join(map(repr, self.slots))})"

class Category:
    def __init__ (self, name : str, orbament_wide : bool):
        self.name = name
        self.orbament_wide = orbament_wide

    def __repr__ (self):
        return f"{self.name}" + "*" if self.orbament_wide else ""

class Quartz:
    def __init__ (self, name : str, category : Category, element : Element, power : Power):
        self.name = name
        self.category = category
        self.element = element
        self.power = power

    def __repr__ (self):
        return colour(self.element, f"{self.name}")

class Art:
    def __init__ (self, name : str, element : Element, reqs : Power):
        self.name = name
        self.element = element
        self.reqs = reqs

    def __repr__ (self):
        return colour(self.element, f"{self.name}")

def search (lst, name):
    for item in lst:
        if item.name == name:
            return item
    return None

septium_vein_category = Category("Categoría veta de septium", True)
heal_category = Category("Categoría curación", True)
mercy_category = Category("Categoría compasión", True)
ingenuity_category = Category("Categoría ingenio", True)
sweet_aroma_category = Category("Categoría dulce aroma", True)
great_fortune_category = Category("Categoría gran fortuna", True)
heavenly_insight_category = Category("Categoría percepción celestial", True)
heat_haze_category = Category("Categoría neblina ardiente", True)

blade_category = Category("Categoría hoja", False)
shield_category = Category("Categoría escudo", False)

defense_category = Category("Categoría defensa", True)
break_category = Category("Categoría rotura", True)
mind_category = Category("Categoría mente", True)
hp_category = Category("Categoría pV", True)
attack_category = Category("Categoría ataque", True)
strike_category = Category("Categoría crítico", True)
arts_defense_category = Category("Categoría defensa de artes", True)
evade_category = Category("Categoría evasión", True)
fury_category = Category("Categoría furia", True)
action_category = Category("Categoría acción", True)
cast_category = Category("Categoría artes", True)
hit_category = Category("Categoría precisión", True)
ep_cut_category = Category("Categoría ahorro de PE", True)
impede_category = Category("Categoría anulación", True)
ep_category = Category("Categoría PE", True)

categories = [
    septium_vein_category,
    heal_category,
    mercy_category,
    ingenuity_category,
    sweet_aroma_category,
    great_fortune_category,
    heavenly_insight_category,
    heat_haze_category,

    blade_category,
    shield_category,

    defense_category,
    break_category,
    mind_category,
    hp_category,
    attack_category,
    strike_category,
    arts_defense_category,
    evade_category,
    fury_category,
    action_category,
    cast_category,
    hit_category,
    ep_cut_category,
    impede_category,
    ep_category,
]

quartz = [
    # ==== Cuarzos de Tierra ================================================ #
    Quartz("Defensa 1", defense_category, Element.Earth, {Element.Earth: 1}),
    Quartz("Defensa 2", defense_category, Element.Earth, {Element.Earth: 2}),
    Quartz("Defensa 3", defense_category, Element.Earth, {Element.Earth: 3}),
    Quartz("Defensa 3+", defense_category, Element.Earth, {Element.Earth: 3}),
    Quartz("Rotura 1", break_category, Element.Earth, {Element.Earth: 1}),
    Quartz("Rotura 2", break_category, Element.Earth, {Element.Earth: 2}),
    Quartz("Rotura 3", break_category, Element.Earth, {Element.Earth: 3}),
    Quartz("Rotura 3+", break_category, Element.Earth, {Element.Earth: 3}),
    Quartz("Hoja envenenada", blade_category, Element.Earth,
           {Element.Earth: 1}),
    Quartz("Hoja petrificadora", blade_category, Element.Earth,
           {Element.Earth: 2}),
    Quartz("Escudo de topacio", shield_category, Element.Earth,
           {Element.Earth: 2, Element.Mirage: 2}),
    Quartz("Veta de septium", septium_vein_category, Element.Earth,
           {Element.Earth: 3, Element.Wind: 3}),

    # ==== Cuarzos de Agua ================================================== #
    Quartz("Mente 1", mind_category, Element.Water, {Element.Water: 1}),
    Quartz("Mente 2", mind_category, Element.Water, {Element.Water: 2}),
    Quartz("Mente 3", mind_category, Element.Water, {Element.Water: 3}),
    Quartz("Mente 3+", mind_category, Element.Water, {Element.Water: 3}),
    Quartz("PV 1", hp_category, Element.Water, {Element.Water: 1}),
    Quartz("PV 2", hp_category, Element.Water, {Element.Water: 2}),
    Quartz("PV 3", hp_category, Element.Water, {Element.Water: 3}),
    Quartz("PV 3+", hp_category, Element.Water, {Element.Water: 3}),
    Quartz("Hoja congelante", blade_category, Element.Water,
           {Element.Water: 2}),
    Quartz("Escudo de zafiro", shield_category, Element.Water,
           {Element.Water: 2, Element.Fire: 2}),
    Quartz("Curación", heal_category, Element.Water,
           {Element.Water: 2, Element.Wind: 2}),
    Quartz("Compasión", mercy_category, Element.Water,
           {Element.Water: 3, Element.Earth: 3}),

    # ==== Cuarzos de Fuego ================================================= #
    Quartz("Ataque 1", attack_category, Element.Fire, {Element.Fire: 1}),
    Quartz("Ataque 2", attack_category, Element.Fire, {Element.Fire: 2}),
    Quartz("Ataque 3", attack_category, Element.Fire, {Element.Fire: 3}),
    Quartz("Ataque 3+", attack_category, Element.Fire, {Element.Fire: 3}),
    Quartz("Crítico 1", strike_category, Element.Fire, {Element.Fire: 1}),
    Quartz("Crítico 2", strike_category, Element.Fire, {Element.Fire: 2}),
    Quartz("Crítico 3", strike_category, Element.Fire, {Element.Fire: 3}),
    Quartz("Crítico 3+", strike_category, Element.Fire, {Element.Fire: 3}),
    Quartz("Hoja abrasadora", blade_category, Element.Fire,
           {Element.Fire: 1}),
    Quartz("Hoja selladora", blade_category, Element.Fire,
           {Element.Fire: 2}),
    Quartz("Escudo de rubí", shield_category, Element.Fire,
           {Element.Fire: 2, Element.Earth: 2}),
    Quartz("Ingenio", ingenuity_category, Element.Fire,
           {Element.Fire: 3, Element.Wind: 3}),

    # ==== Cuarzos de Viento ================================================ #
    Quartz("Defensa de artes 1", arts_defense_category, Element.Wind,
           {Element.Wind: 1}),
    Quartz("Defensa de artes 2", arts_defense_category, Element.Wind,
           {Element.Wind: 2}),
    Quartz("Defensa de artes 3", arts_defense_category, Element.Wind,
           {Element.Wind: 3}),
    Quartz("Defensa de artes 3+", arts_defense_category, Element.Wind,
           {Element.Wind: 3}),
    Quartz("Evasión 1", evade_category, Element.Wind, {Element.Wind: 1}),
    Quartz("Evasión 2", evade_category, Element.Wind, {Element.Wind: 2}),
    Quartz("Evasión 3", evade_category, Element.Wind, {Element.Wind: 3}),
    Quartz("Evasión 3+", evade_category, Element.Wind, {Element.Wind: 3}),
    Quartz("Hoja somnífera", blade_category, Element.Wind, {Element.Wind: 2}),
    Quartz("Escudo de esmeralda", shield_category, Element.Wind,
           {Element.Wind: 2, Element.Space: 2}),
    Quartz("Dulce aroma", sweet_aroma_category, Element.Wind,
           {Element.Wind: 3, Element.Earth: 3, Element.Water: 3,
            Element.Fire: 3}),
    Quartz("Furia", fury_category, Element.Wind,
           {Element.Wind: 3, Element.Time: 3}),

    # ==== Cuarzos de Tiempo ================================================ #
    Quartz("Acción 1", action_category, Element.Time, {Element.Time: 1}),
    Quartz("Acción 2", action_category, Element.Time, {Element.Time: 2}),
    Quartz("Acción 3", action_category, Element.Time, {Element.Time: 3}),
    Quartz("Acción 3+", action_category, Element.Time, {Element.Time: 3}),
    Quartz("Artes 1", cast_category, Element.Time,
           {Element.Time: 1, Element.Mirage: 1}),
    Quartz("Artes 2", cast_category, Element.Time,
           {Element.Time: 2, Element.Space: 1, Element.Mirage: 2}),
    Quartz("Artes 3", cast_category, Element.Time,
           {Element.Time: 3, Element.Space: 2, Element.Mirage: 3}),
    Quartz("Artes 3+", cast_category, Element.Time,
           {Element.Time: 3, Element.Space: 2, Element.Mirage: 3}),
    Quartz("Hoja ciega", blade_category, Element.Time,
           {Element.Time: 1}),
    Quartz("Hoja mortal", blade_category, Element.Time,
           {Element.Time: 3}),
    Quartz("Escudo oscuro", shield_category, Element.Time,
           {Element.Time: 3, Element.Water: 3}),
    Quartz("Gran fortuna", great_fortune_category, Element.Time,
           {Element.Time: 5, Element.Earth: 5}),

    # ==== Cuarzos de Espacio =============================================== #
    Quartz("Precisión 1", hit_category, Element.Space, {Element.Space: 1}),
    Quartz("Precisión 2", hit_category, Element.Space, {Element.Space: 2}),
    Quartz("Precisión 3", hit_category, Element.Space, {Element.Space: 3}),
    Quartz("Precisión 3+", hit_category, Element.Space, {Element.Space: 3}),
    Quartz("Ahorro de PE 1", ep_cut_category, Element.Space,
           {Element.Space: 1, Element.Time: 1}),
    Quartz("Ahorro de PE 2", ep_cut_category, Element.Space,
           {Element.Space: 2, Element.Time: 2, Element.Mirage: 1}),
    Quartz("Ahorro de PE 3", ep_cut_category, Element.Space,
           {Element.Space: 3, Element.Time: 3, Element.Mirage: 2}),
    Quartz("Ahorro de PE 3+", ep_cut_category, Element.Space,
           {Element.Space: 3, Element.Time: 3, Element.Mirage: 2}),
    Quartz("Hoja muda", blade_category, Element.Space,
           {Element.Space: 3}),
    Quartz("Escudo dorado", shield_category, Element.Space,
           {Element.Space: 3, Element.Earth: 3}),
    Quartz("Percepción celestial", heavenly_insight_category, Element.Space,
           {Element.Space: 5, Element.Water: 5}),
    Quartz("Hoja solitaria", blade_category, Element.Space,
           {Element.Space: 5, Element.Fire: 5}),

    # ==== Cuarzos de Espejismo ============================================= #
    Quartz("Anulación 1", impede_category, Element.Mirage,
           {Element.Mirage: 1}),
    Quartz("Anulación 2", impede_category, Element.Mirage,
           {Element.Mirage: 2}),
    Quartz("Anulación 3", impede_category, Element.Mirage,
           {Element.Mirage: 3}),
    Quartz("Anulación 3+", impede_category, Element.Mirage,
           {Element.Mirage: 3}),
    Quartz("PE 1", ep_category, Element.Mirage,
           {Element.Mirage: 1, Element.Space: 1}),
    Quartz("PE 2", ep_category, Element.Mirage,
           {Element.Mirage: 2, Element.Time: 1, Element.Space: 2}),
    Quartz("PE 3", ep_category, Element.Mirage,
           {Element.Mirage: 3, Element.Time: 2, Element.Space: 3}),
    Quartz("PE 3+", ep_category, Element.Mirage,
           {Element.Mirage: 3, Element.Time: 2, Element.Space: 3}),
    Quartz("Hoja caótica", blade_category, Element.Mirage,
           {Element.Mirage: 3}),
    Quartz("Escudo plateado", shield_category, Element.Mirage,
           {Element.Mirage: 3, Element.Fire: 3}),
    Quartz("Neblina ardiente", heat_haze_category, Element.Mirage,
           {Element.Mirage: 3, Element.Time: 3, Element.Space: 3}),
    Quartz("Hoja oculta", blade_category, Element.Mirage,
           {Element.Mirage: 5, Element.Wind: 5}),
]

arts = [
    # ==== Artes de Tierra ================================================== #
    Art("Martillo pétreo", Element.Earth, {Element.Earth: 1}),
    Art("Lanza de tierra", Element.Earth, {Element.Earth: 2}),
    Art("Vaho petrificante", Element.Earth, {Element.Earth: 3,
                                             Element.Wind: 2}),
    Art("Impacto pétreo", Element.Earth, {Element.Earth: 4}),
    Art("Rugido titánico", Element.Earth, {Element.Earth: 5,
                                           Element.Space: 3}),
    Art("Favor térreo", Element.Earth, {Element.Earth: 2,
                                        Element.Mirage: 2}),
    Art("Pared de tierra", Element.Earth, {Element.Earth: 4,
                                           Element.Space: 3}),
    Art("Emblema", Element.Earth, {Element.Earth: 1,
                                   Element.Mirage: 1}),

    # ==== Artes de Agua ==================================================== #
    Art("Ataque acuático", Element.Water, {Element.Water: 1}),
    Art("Impacto azul", Element.Water, {Element.Water: 3}),
    Art("Polvo de diamante", Element.Water, {Element.Water: 5,
                                             Element.Space: 5}),
    Art("Lágrima", Element.Water, {Element.Water: 1}),
    Art("Lágrima+", Element.Water, {Element.Water: 3}),
    Art("Lágrima++", Element.Water, {Element.Water: 5}),
    Art("Gran lágrima", Element.Water, {Element.Water: 2,
                                        Element.Space: 2}),
    Art("Gran lágrima+", Element.Water, {Element.Water: 4,
                                         Element.Space: 2,
                                         Element.Wind: 2}),
    Art("Curalotodo", Element.Water, {Element.Water: 1,
                                      Element.Mirage: 1}),
    Art("Gran curalotodo", Element.Water, {Element.Water: 3,
                                           Element.Mirage: 2}),
    Art("Celestial", Element.Water, {Element.Water: 4,
                                     Element.Space: 2}),

    # ==== Artes de Fuego =================================================== #
    Art("Bola ígnea", Element.Fire, {Element.Fire: 1}),
    Art("Flecha ígnea", Element.Fire, {Element.Fire: 2}),
    Art("Llama explosiva", Element.Fire, {Element.Fire: 2,
                                          Element.Wind: 2}),
    Art("Flecha ígnea+", Element.Fire, {Element.Fire: 4}),
    Art("Espiral ardiente", Element.Fire, {Element.Fire: 5,
                                           Element.Wind: 2,
                                           Element.Space: 4}),
    Art("Ruina volcánica", Element.Fire, {Element.Fire: 5,
                                          Element.Earth: 3,
                                          Element.Mirage: 5}),
    Art("Fortaleza", Element.Fire, {Element.Fire: 1,
                                    Element.Mirage: 1}),

    # ==== Artes de Viento ================================================== #
    Art("Ráfaga de aire", Element.Wind, {Element.Wind: 1}),
    Art("Tornado", Element.Wind, {Element.Wind: 3}),
    Art("Ciclón", Element.Wind, {Element.Wind: 4,
                                 Element.Time: 2,
                                 Element.Mirage: 2}),
    Art("Rayo", Element.Wind, {Element.Wind: 3,
                               Element.Space: 2}),
    Art("Oleada lumínica", Element.Wind, {Element.Wind: 5,
                                          Element.Fire: 3,
                                          Element.Space: 5}),
    Art("Favor silfídico", Element.Wind, {Element.Wind: 2,
                                          Element.Mirage: 2}),
    Art("Ala silfídica", Element.Wind, {Element.Wind: 4,
                                        Element.Mirage: 4}),

    # ==== Artes de Tiempo ================================================== #
    Art("Alama nublada", Element.Time, {Element.Time: 1}),
    Art("Lanza oscura", Element.Time, {Element.Time: 2}),
    Art("Puerata al infierno", Element.Time, {Element.Time: 3,
                                              Element.Fire: 2,
                                              Element.Space: 2}),
    Art("Averno blanco", Element.Time, {Element.Time: 5,
                                        Element.Mirage: 5}),
    Art("Acelerador", Element.Time, {Element.Time: 1,
                                     Element.Space: 1}),
    Art("Acelerador+", Element.Time, {Element.Time: 3,
                                      Element.Space: 3}),
    Art("Antiseptium", Element.Time, {Element.Time: 2,
                                      Element.Mirage: 2}),
    Art("Gran antiseptium", Element.Time, {Element.Time: 3,
                                           Element.Mirage: 3}),

    # ==== Artes de Espejismo =============================================== #
    Art("Santificación", Element.Mirage, {Element.Mirage: 2,
                                          Element.Water: 1,
                                          Element.Wind: 1,
                                          Element.Space: 1}),
    Art("Marga del caos", Element.Mirage, {Element.Mirage: 3}),
]


orbaments = [
    # Counter-clockwise from 12 o'clock
    Orbament("Estelle",
             [Slot(1), Slot(2), Slot(3),
              Slot(4), Slot(5), Slot(6)],
             [[1, 2, 3, 4], [4, 5, 6]]),
    Orbament("Joshua", 
             [Slot(1, Element.Time), Slot(2), Slot(3),
              Slot(4, Element.Time), Slot(5), Slot(6)],
             [[1, 2, 3, 4, 6], [4, 5]]),
    Orbament("Scherzard",
             [Slot(1), Slot(2), Slot(3),
              Slot(4, Element.Wind), Slot(5), Slot(6, Element.Wind)],
             [[1, 2, 4, 5, 6], [3, 4]]),
    Orbament("Olivier",
             [Slot(1), Slot(2), Slot(3),
              Slot(4, Element.Mirage), Slot(5), Slot(6)],
             [[1, 2, 3, 4, 5, 6]]),
]

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

if __name__ == "__main__":
    if len(sys.argv) != 1:
        print(f"USAGE: {sys.argv[0]}")
        exit(1)
    max_n = max_number()

    print("; vim: ft=scheme")
    print("(define (problem orbament-settings-layout)")
    print("  (:domain orbament-settings)")

    # TODO: Filtrar del JSON los elementos y los personajes
    # Si un arte requiere 0 o provee 0, se puede eliminar.

    # Declare global objects

    put(1, "(:objects")
    peanno_objects(max_n)
    element_objects()
    category_objects()
    quartz_objects()
    art_objects()
    orbament_objects()
    print(")")

    # Initialise object relationships

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

    # Set up the "real" initial configuration.
    # TODO: Cargar esto de un JSON con la misma estructura:

    raw_inventory = {
        # search(quartz, "Defensa 1"): 2,
        "Hoja petrificadora": 0,
        "Ataque 1": 0,
        # search(quartz, "Defensa 3"): 1,
    }

    raw_config = {
        "Joshua" : {
            4 : "PV 2"
        }
    }

    inventory = {search(quartz, key) : value
                 for key, value in raw_inventory.items()}
    config = {search(orbaments, o)
              : {search(orbaments, o).slots[s - 1] : search(quartz, q)
                 for s, q in value.items()}
              for o, value in raw_config.items()}

    put(2, ";;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;;")
    put(2, ";; H E R E   G O E S   T H E   I N I T I A L   C O N F I G U R A T I O N  ;;")
    put(2, ";;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;;")
    print()
    put(2, ";;; ~ Quartz count in inventory ~")

    for q in quartz:
        n = inventory[q] if q in inventory else 0
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
                        set(x for x in line for line in lines.values())
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

    # Define the goal

    put(1, "(:goal")
    put(2, "(and")
    put(3, "(action-state)")
    # put(3, "(orbament-active estelle-orbament martillo-petreo)")
    # put(3, "(orbament-active estelle-orbament lagrima)")
    put(3, "(line-active estelle-line-1 lagrima)")
    # put(3, "(not (orbament-active joshua-orbament lagrima))")

    # put(3, "(value earth estelle-line-1 n3)")
    # put(3, "(active estelle-line-1 martillo-petreo)")
    # put(3, "(active estelle-line-1 martillo-petreo)")
    # put(3, "(active estelle-line-2 martillo-petreo)")
    # put(3, "(active estelle-line-2 bola-ignea)")
    # put(3, "(active joshua-line-2 martillo-petreo)")

    print("))")

    # Set up the metric

    put(1, "(:minimize (total-cost))")
    print(")")


