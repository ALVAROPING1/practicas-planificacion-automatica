# *-* encoding=utf8 *-*

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
    def __init__ (self, name : str):
        self.name = name

    def __repr__ (self):
        return f"{self.name}"

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

septium_vein_category = Category("Categoría veta de septium")
heal_category = Category("Categoría curación")
mercy_category = Category("Categoría compasión")
ingenuity_category = Category("Categoría ingenio")
sweet_aroma_category = Category("Categoría dulce aroma")
great_fortune_category = Category("Categoría gran fortuna")
heavenly_insight_category = Category("Categoría percepción celestial")
heat_haze_category = Category("Categoría neblina ardiente")

poison_blade_category = Category("Categoría hoja envenenada")
petrify_blade_category = Category("Categoría hoja petrificadora")
freeze_blade_category = Category("Categoría hoja congelante")
burn_blade_category = Category("Categoría hoja abrasadora")
seal_blade_category = Category("Categoría hoja selladora")
sleep_blade_category = Category("Categoría hoja somnífera")
blind_blade_category = Category("Categoría hoja ciega")
mortal_blade_category = Category("Categoría hoja mortal")
mute_blade_category = Category("Categoría hoja muda")
lone_blade_category = Category("Categoría hoja solitaria")
chaotic_blade_category = Category("Categoría hoja caótica")
hidden_blade_category = Category("Categoría hoja oculta")

topaz_shield_category = Category("Categoría escudo de topacio")
saphire_shield_category = Category("Categoría escudo de zafiro")
ruby_shield_category = Category("Categoría escudo de rubí")
emerald_shield_category = Category("Categoría escudo de esmeralda")
dark_shield_category = Category("Categoría escudo oscuro")
golden_shield_category = Category("Categoría escudo dorado")
silver_shield_category = Category("Categoría escudo plateado")

defense_category = Category("Categoría defensa")
break_category = Category("Categoría rotura")
mind_category = Category("Categoría mente")
hp_category = Category("Categoría PV")
attack_category = Category("Categoría ataque")
strike_category = Category("Categoría crítico")
arts_defense_category = Category("Categoría defensa de artes")
evade_category = Category("Categoría evasión")
fury_category = Category("Categoría furia")
action_category = Category("Categoría acción")
cast_category = Category("Categoría artes")
hit_category = Category("Categoría precisión")
ep_cut_category = Category("Categoría ahorro de PE")
impede_category = Category("Categoría anulación")
ep_category = Category("Categoría PE")

categories = [
    septium_vein_category,
    heal_category,
    mercy_category,
    ingenuity_category,
    sweet_aroma_category,
    great_fortune_category,
    heavenly_insight_category,
    heat_haze_category,

    poison_blade_category,
    petrify_blade_category,
    freeze_blade_category,
    burn_blade_category,
    seal_blade_category,
    sleep_blade_category,
    blind_blade_category,
    mortal_blade_category,
    mute_blade_category,
    lone_blade_category,
    chaotic_blade_category,
    hidden_blade_category,

    topaz_shield_category,
    saphire_shield_category,
    ruby_shield_category,
    dark_shield_category,
    emerald_shield_category,
    golden_shield_category,
    silver_shield_category,

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
    Quartz("Hoja envenenada", poison_blade_category, Element.Earth,
           {Element.Earth: 1}),
    Quartz("Hoja petrificadora", petrify_blade_category, Element.Earth,
           {Element.Earth: 2}),
    Quartz("Escudo de topacio", topaz_shield_category, Element.Earth,
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
    Quartz("Hoja congelante", freeze_blade_category, Element.Water,
           {Element.Water: 2}),
    Quartz("Escudo de zafiro", saphire_shield_category, Element.Water,
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
    Quartz("Hoja abrasadora", burn_blade_category, Element.Fire,
           {Element.Fire: 1}),
    Quartz("Hoja selladora", seal_blade_category, Element.Fire,
           {Element.Fire: 2}),
    Quartz("Escudo de rubí", ruby_shield_category, Element.Fire,
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
    Quartz("Hoja somnífera", sleep_blade_category, Element.Wind, {Element.Wind: 2}),
    Quartz("Escudo de esmeralda", emerald_shield_category, Element.Wind,
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
    Quartz("Hoja ciega", blind_blade_category, Element.Time,
           {Element.Time: 1}),
    Quartz("Hoja mortal", mortal_blade_category, Element.Time,
           {Element.Time: 3}),
    Quartz("Escudo oscuro", dark_shield_category, Element.Time,
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
    Quartz("Hoja muda", mute_blade_category, Element.Space,
           {Element.Space: 3}),
    Quartz("Escudo dorado", golden_shield_category, Element.Space,
           {Element.Space: 3, Element.Earth: 3}),
    Quartz("Percepción celestial", heavenly_insight_category, Element.Space,
           {Element.Space: 5, Element.Water: 5}),
    Quartz("Hoja solitaria", lone_blade_category, Element.Space,
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
    Quartz("Hoja caótica", chaotic_blade_category, Element.Mirage,
           {Element.Mirage: 3}),
    Quartz("Escudo plateado", silver_shield_category, Element.Mirage,
           {Element.Mirage: 3, Element.Fire: 3}),
    Quartz("Neblina ardiente", heat_haze_category, Element.Mirage,
           {Element.Mirage: 3, Element.Time: 3, Element.Space: 3}),
    Quartz("Hoja oculta", hidden_blade_category, Element.Mirage,
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
    Art("Protección de tierra", Element.Earth, {Element.Earth: 2,
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
    Art("Alma nublada", Element.Time, {Element.Time: 1}),
    Art("Lanza oscura", Element.Time, {Element.Time: 2}),
    Art("Puerta al infierno", Element.Time, {Element.Time: 3,
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
    Art("Marca del caos", Element.Mirage, {Element.Mirage: 3}),
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
    Orbament("Scherazard",
             [Slot(1), Slot(2), Slot(3),
              Slot(4, Element.Wind), Slot(5), Slot(6, Element.Wind)],
             [[1, 2, 4, 5, 6], [3, 4]]),
    Orbament("Olivier",
             [Slot(1), Slot(2), Slot(3),
              Slot(4, Element.Mirage), Slot(5), Slot(6)],
             [[1, 2, 3, 4, 5, 6]]),
]

def simplify_domain (json : dict):
    if "characters" in json:
        for i in range(len(orbaments) - 1, -1, -1):
            o = orbaments[i]
            if o.name not in json["characters"]:
                del orbaments[i]
                print(f";;;; Disabled character {o.name}")
    strict = json["strict"] == "true" if "strict" in json else False
    if "elements" in json:
        for e in Element:
            if e.name in json["elements"]: continue
            print(f";;;; Disabled element {e.name}")
            for i in range(len(arts) - 1, -1, -1):
                a = arts[i]
                if strict and e in a.reqs:
                    del arts[i]
                    print(f";;;; - Disabled art {a.name}")
                elif not strict and e in a.reqs:
                    del a.reqs[e]
                    if a.reqs == {}:
                        del arts[i]
                        print(f";;;; - Disabled art {a.name}")
            for i in range(len(quartz) - 1, -1, -1):
                q = quartz[i]
                if strict and e in q.power:
                    del quartz[i]
                    print(f";;;; - Disabled quartz {q.name}")
                elif not strict and e in q.power:
                    del q.power[e]
                    if q.power == {}:
                        del quartz[i]
                        print(f";;;; - Disabled quartz {q.name}")
