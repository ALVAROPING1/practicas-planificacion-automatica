#import "@preview/touying:0.6.1": *
#import themes.stargazer: *
#import "@preview/numbly:0.1.0": numbly

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/lilaq:0.4.0" as lq
#import "@preview/cetz:0.3.4" as cetz
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge, shapes

#show: codly-init.with()

#let azuluc3m = rgb("#000e78")

#set text(
  lang:   "es",
  region: "es")

#show: stargazer-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Planifiación Automática -- Práctica Final],
    subtitle: [Configurador de orbamentos],
    author: [Álvaro Guerrero Espinosa (100472294)\
             José Antonio Verde Jiménez (100472221)],
    date: [12 de enero de 2026],
    institution: [Universidad Carlos III de Madrid],
    // logo: rect(image("uc3m_logo.svg"), fill: white),
  ),
  footer-a: (self => [A. Guerrero Espinosa & J. A. Verde Jiménez]),
)

#show table: block.with(stroke: (y: 0.7pt))
#set table(
  row-gutter: 0.2em,   // Row separation
  stroke: (_, y) => if y == 0 { (bottom: 0.2pt) }
)



#set heading(numbering: numbly("{1}.", default: "1.1"))

// TODO: Reemplazar con los cut-outs de los logos

#let earth-color(s, weight: "normal")  = text(s, weight: weight, fill: rgb("#de8b2e"))
#let water-color(s, weight: "normal")  = text(s, weight: weight, fill: rgb("#4fc5f3"))
#let fire-color(s, weight: "normal")   = text(s, weight: weight, fill: rgb("#b42322"))
#let wind-color(s, weight: "normal")   = text(s, weight: weight, fill: rgb("#277f4b"))
#let time-color(s, weight: "normal")   = text(s, weight: weight, fill: rgb("#1b1628"))
#let space-color(s, weight: "normal")  = text(s, weight: weight, fill: rgb("#baa821"))
#let mirage-color(s, weight: "normal") = text(s, weight: weight, fill: rgb("#555555"))

// #let from-icon(colour, kanji, source) = colour(kanji, weight: "bold")
#let from-icon(colour, kanji, source) = box(image(source, height: 1em, fit: "contain"), baseline: 2pt)
#let earth  = from-icon(earth-color, "土", "Earth.png")
#let water  = from-icon(water-color, "水", "Water.png")
#let fire   = from-icon(fire-color, "火", "Fire.png")
#let wind   = from-icon(wind-color, "風", "Wind.png")
#let time   = from-icon(time-color, "時", "Time.png")
#let space  = from-icon(space-color, "空", "Space.png")
#let mirage = from-icon(mirage-color, "幻", "Mirage.png")

#title-slide()

= Dominio
== Descripción
#slide[
- *Dominio*: configurador de orbamentos.
- Cada personaje tiene un *orbamento*.
- Cada orbamento tiene *6 ranuras*.
- Las ranuras están conectadas por *líneas*.
- En ranuras se pueden insertar *cuarzos*.
- Hay *restricciones* entre cuarzos.
- Hay *7 elementos*:
  #earth-color("tierra", weight: "bold") #earth,
  #water-color("agua", weight: "bold") #water,
  #fire-color("fuego", weight: "bold") #fire,
  #wind-color("viento", weight: "bold") #wind,
  #time-color("tiempo", weight: "bold") #time,
  #space-color("espacio", weight: "bold") #space e
  #mirage-color("ilusión", weight: "bold") #mirage.
- Cada *cuarzo* da un poder elemental ($bb(N)$) para cada uno de los elementos.
][
  #figure(image("orbamento-vacío.png", height: 90%),
          caption: [Orbamento vacío])
]

#slide[
  #figure(
    image("panel-artes.png", height: 80%),
    caption: [Ejemplo de artes que se pueden activar])
][
- Una *arte* se activa en un *orbamento* si existe alguna *línea* para la que
  todos los *elementos* tienen valor suficiente.
- Cada *cuarzo* pertenece a una *categoría*.
  - Dos cuarzos de la misma categoría no pueden estar en el mismo orbamento.
- El dominio es igual en los cinco primeros juegos de la saga (pequeñas
  variaciones).
]

== Ejemplo
#slide[
  // Empezando desde las 12 en sentido antihorario
- Configuración
  - Escudo de topacio (+2 #earth, +2 #mirage).
  - Precisión 2 (+2 #space).
  - Rotura 2 (+2 #earth).
  - Ataque 2 (+2 #fire).
  - Hoja petrificadora (+2 #fire).
  - PE 2 (+1 #time, +2 #space, +2 #mirage).
- Total
  - Línea 1: 4 #earth, 2 #fire, 2 #space, 2 #mirage
  - Línea 2: 4 #fire, 1 #time, 2 #space, 2 #mirage
][
  #figure(image("orbamento-ejemplo.png", height: 90%),
          caption: [Ejemplo de configuración.])
]

#slide[
Se activan las artes:
- Martillo pétreo ($>= 1$ #earth)
- Lanza de tierra ($>= 2$ #earth)
- Impacto pétreo ($>= 4$ #earth)
- Protección de tierra ($>= 2$ #earth $and$ $>= 2$ #mirage)
- Emblema ($>= 1$ #earth $and$ $>= 1$ #mirage)
- Bola ígnea ($>= 1$ #fire)
- Flecha ígnea ($>= 2$ #fire)
- Fortaleza ($>= 1$ #fire $and$ $>= 1$ #mirage)
- Alma nublada ($>= 1$ #time)
- Acelerador ($>= 1$ #time $and$ $>= 1$ #mirage)
][
No se activaría por ejemplo:
- Pared de tierra ($>= 4$ #earth $and$ $>= 3$ #space) \
  Porque falta uno de #space.

- Las líneas son independientes.
- Pueden compartir ranuras.
- La activación de artes es independiente.
]

== Complicaciones y soluciones
- Utilizamos `fast-downward`
  - Muchos competidores de _I.P.C. 2023 Classical Tracks_ parten de o usan
    `fast-downward`.
  - *No soporta _fluents_* (excepto `total-cost`).
  - El dominio usa mucho sumas y restas.
- No soporta cuantificadores universales en los efectos.
  - Insertar en una ranura puede modificar varias líneas.
  - Una inserción o eliminación puede activar y desactivar muchas artes.

#slide[
Definimos el tipo `natural` ($bb(N)$).
- Los objetos `n0`, `n1`, `n2`, ...
- Relaciones entre ellos:
  - `(addition ?lhs ?rhs ?r - natural)`
    - `(addition n2 n3 n5)`
    - `(addition n0 n3 n3)`
    - Se puede usar para sumar y restar.
  - `(less-than ?lhs ?rhs)`
    - `(less-than n0 n1)`
    - `(less-than n3 n7)`
    - Con `not` y `and` y cambiando el orden se puede definir el resto de
      operaciones: $<=$, $<$, $=$, $>$, $>=$, $!=$.
][
- Necesitamos tres parámetros por operación.
  - ¡Si queremos hacer sumas para los 7 elementos, necesitaríamos mínimo 21
    parámetros!
  - Si se tienen que instanciar todas las acciones, ignorando combinaciones
    imposibles, para 22 naturales habría $21^22 approx 1.23 dot.c 10^(29)$
    objetos (97 bits).
    // Comentar que identifica combinaciones imposibles y las elimina.
- Las operaciones se tienen que hacer por pasos.
]

#slide[
#set text(13pt)
#figure(
  diagram(
    node-stroke: 1pt,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 3.8em,
    {
      let radius = 2.7em
      node((0,1), [Action], radius: radius, extrude: (-2.5, 0))

      edge(`insert`, "-|>")
      node((1,0), [Restrict], radius: radius)
      edge((1,0), (1,0), `restrict`, "-|>", bend: -110deg)
      edge(`end-restrict`, "-|>")
      node((3,0), [Addition], radius: radius)
      edge((3,0), (3,0), [`add-element`\ `add-line`], "-|>", bend: -110deg)
      edge(`end-addition`, "-|>")
      node((5,0), [Activation], radius: radius)
      edge((5,0), (5,0), [`activate`], "-|>", bend: -110deg)
      edge((5,0), (6,1), `end-activation`, "-|>")

      edge((0,1), (1,2), `remove`, "-|>", bend: -1deg)
      node((1,2), [Unrestrict], radius: radius)
      edge((1,2), (1,2), `unrestrict`, "-|>", bend: 110deg)
      edge(`end-unrestrict`, "-|>")
      node((3,2), [Subtraction], radius: radius)
      edge((3,2), (3,2), [`sub-element`\ `sub-line`], "-|>", bend: 110deg)
      edge(`end-subtraction`, "-|>")
      node((5,2), [Deactivation], radius: radius)
      edge((5,2), (5,2), [`deactivate`], "-|>", bend: 110deg)
      edge(`end-deactivation`, "-|>", label-pos: 0.8)

      node((6,1), [Unmark], radius: radius)
      edge((6,1), (0,1), `end-unmark`, "-|>")
      edge((6,1), (6,1), [`unmark-art`\ `unmark-line`\ `unmark-art`], "-|>", bend: -130deg)
    }
  ),
)
]

#slide[

  // NOTA: LA DESCRIPCIÓN ESTÁ EN EL MEDIO DE AMBAS MÁQUINAS DE ESTADO PARA
  //       IR PARA ATRÁS Y HACIA DELANTE AL HABLAR DE ELLAS.

*Solución: una máquina de estados*

- Cada estado es un predicado de aridad cero.
- Se pueden colapsar el estado de activation y deactivation en uno solo, pero
  no mejora.
- En vez de la etapa de activación y desactivación decidimos utilizar *axiomas*
  o _*derived*_.
  - Da mejor rendimiento, del orden de pasar de días a segundos.
- No es necesario restringir las ranuras independientemente.
  - Se eliminan el estado _restrict_ y _unrestrict_.

// TODO: Describir problemas: unmark arts
]

#slide[
#set text(13pt)
#figure(
  diagram(
    node-stroke: 1pt,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 3.8em,
    {
      let radius = 2.7em
      node((0,1), [Action], radius: radius, extrude: (-2.5, 0))

      edge(`insert`, "-|>")
      node((3,0), [Addition], radius: radius)
      edge((3,0), (3,0), [`element-addition`\ `finish-line-addition`], "-|>", bend: -110deg)
      edge((3,0), (6,1), `end-addition`, "-|>")

      edge((0,1), (3,2), `remove`, "-|>", bend: -1deg)  // Para que aparezca abajo
      node((3,2), [Subtraction], radius: radius)
      edge((3,2), (3,2), [`element-subtraction`\ `finish-line-subtraction`], "-|>", bend: 110deg)
      edge(`end-subtraction`, "-|>", bend: -1deg)

      node((6,1), [Unmark], radius: radius)
      edge((6,1), (0,1), `end-unmark`, "-|>")
      edge((6,1), (6,1), [`unmark-element`\ `unmark-line`], "-|>", bend: -130deg, loop-angle: 180deg)

    }
  ),
)
]

== PDDL

#slide[
- Tipos
  - `natural element - object`
  - `quartz art category - object`
  - `slot line orbament - object`
#[
- Axiomas / _Derived_
  #set text(size: 16pt)
  - `(enough-power-for-element` \ `?e - element ?l - line ?a - art)`
  - `(line-active ?l - line ?a - art)`
  - `(orbament-active ?o - orbament ?a - art)`
  - `(any-active ?a - art)`
]
][
- Predicados
  #set text(size: 13pt)
  - `(addition ?lhs ?rhs ?res - natural)`
  - `(less-than ?lhs ?rhs - natural)`
  - `(inventory-count ?q - quartz ?n - natural)`
  - `(power ?e - element ?q - quartz ?power - natural)`
  - `(belongs ?q - quartz ?c - category)`
  - `(requirement ?e - element ?a - art ?n - natural)`
  - `(contains-slot ?o - orbament ?s - slot)`
  - `(contains-line ?o - orbament ?l - line)`
  - `(connects ?l - line ?s - slot)`
  - `(quartz-element ?q - quartz ?e - element)`
  - `(slot-can-hold ?s - slot ?e - element)`
  - `(value ?e - element ?l - line ?n - natural)`
  - `(contains-quartz ?s - slot ?q - quartz)`
  - `(restricted ?o - orbament ?c - category)`
  - `(filled ?s - slot)`
  - `(quartz-to-be-modified ?q - quartz)`
  - `(category-to-be-modified ?c - category)`
  - `(slot-to-be-modified ?s - slot)`
  - `(orbament-to-be-modified ?o - orbament)`
]


= Problema
== Generación

- Definición compleja del dominio
  - Muchos objetos compartidos (naturales, orbamentos, cuarzos, artes, ...)
  - Muchos predicados base (`addition`, `less-than`).
  - Muchos predicados compartidos para definir los orbamentos, quarzos, artes,
    restricciones...
- *Solución: metaprogramación de los problemas*
  - Problema definido en un `JSON` que se transforma a PDDL.
  - El `JSON` define los elementos y orbamentos permitidos, el estado inicial
    del inventario y los orbamentos, y las metas.
  - Durante la transformación, se añaden los objetos y predicados comunes a todos los
    problemas.

== Pruebas y casos de uso

+ Insertar un cuarzo.
+ Activar todas las artes de un tipo dado.
+ Activar todas las artes.
+ Activar todas las artes con un solo orbamento.
+ Activar todas las artes, empezando con todos los orbamentos llenos.
+ Activar todas las artes, empezando con todos los orbamentos llenos y sin usar
  los mejores quarzos.

= Pruebas y resultados

== Planificadores

- Fast-downward
  - `Lama-first`
  - `Seq-sat-lama-2011`
- Otros planificadores intentados
  - Odin (`planner2`)
  - SymDB (`planner14`)
  - DecStar-2023 (`planner15`)
  - Scorpion 2023 (`planner25`) Sat
  - Approximate Novelty (`planner29`)
  - Problema: no soportan axiomas.

== Problema 1
#[
#set text(12pt)
#table(
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto),
  align: center + horizon,
  table.header(
    [*Planificador*],
    [*Tiempo total*],
    [Tiempo de traducción],
    [Tiempo de búsqueda],
    [*Coste del plan*],
    [Longitud del plan],
    [Nodos expandidos],
    [*Memoria de traducción*],
    [*Memoria de búsqueda*]
  )
)
]


== Resultados
#table()
// TODO: Table

= Conclusiones
== Conclusiones

- Estado actual de los planificadores caótico
  - Ha sido necesario corregir errores de compilación en muchos de los
    planificadores probados.
  - Cada planificador soporta un subconjunto distinto de PDDL.
    // - Las funcionalidades soportadas no coinciden con las versiones de PDDL.
    //   Soportan funcionalidades de PDDL 2.2 sin soportar completamente PDDL 1.2
  - Algunos planificadores utilizan una sintáxis de PDDL un poco distinta.
- Son capaces de resolver problemas complejos de forma eficiente a pesar de ser
  independientes del dominio
  - Se han podido encontrar planes con $> 300$ pasos en un periodo de tiempo
    razonable
