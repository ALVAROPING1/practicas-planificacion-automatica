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

#set heading(numbering: numbly("{1}.", default: "1.1"))

// TODO: Reemplazar con los cut-outs de los logos

#let earth-color(s, weight: "normal")  = text(s, weight: weight, fill: orange)
#let water-color(s, weight: "normal")  = text(s, weight: weight, fill: blue)
#let fire-color(s, weight: "normal")   = text(s, weight: weight, fill: red)
#let wind-color(s, weight: "normal")   = text(s, weight: weight, fill: green)
#let time-color(s, weight: "normal")   = text(s, weight: weight, fill: black)
#let space-color(s, weight: "normal")  = text(s, weight: weight, fill: yellow)
#let mirage-color(s, weight: "normal") = text(s, weight: weight, fill: gray)

#let earth  = earth-color("土", weight: "bold")
#let water  = water-color("水", weight: "bold")
#let fire   = fire-color("火", weight: "bold")
#let wind   = wind-color("風", weight: "bold")
#let time   = time-color("時", weight: "bold")
#let space  = space-color("空", weight: "bold")
#let mirage = mirage-color("幻", weight: "bold")

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
  #earth-color("tierra", weight: "bold"),
  #water-color("agua", weight: "bold"),
  #fire-color("fuego", weight: "bold"),
  #wind-color("viento", weight: "bold"),
  #time-color("tiempo", weight: "bold"),
  #space-color("espacio", weight: "bold") e
  #mirage-color("ilusión", weight: "bold").
- Cada *cuarzo* da un poder elemental ($bb(N)$) para cada uno de los elementos.
- Una *arte* se activa en un *orbamento* si existe alguna *línea* para la que
  todos los *elementos* tienen valor suficiente.
][
  #image("orbamento-vacío.png", height: 90%)
]

#slide[
][
- Cada *cuarzo* pertenece a una *categoría*.
  - Dos cuarzos de la misma categoría no pueden estar en el mismo orbamento.
- El dominio es igual en los cinco primeros juegos de la saga (pequeñas
  variaciones).
  // TODO: Hablar de las relajaciones del dominio: Restricciones a nivel de
  // línea y de elemento del cuarzo
  // Más que relajar: se simplifica el problema, complica buscar soluciones
  // porque ahora la restricción es más fuerte.
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
  #image("orbamento.png", height: 90%)
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
- Aquí es cuando decidimos relajar el dominio y eliminar las restricciones a
  nivel de línea.
  - Se eliminan el estado _restrict_ y _unrestrict_.
  - El problema era una ranura está conectada a más de una línea.
  - No se puede poner un cuantificador universal en el efecto para activar
    todos los predicados de restricciones a nivel de línea.
  - Se puede endurecer la restricción si se asignan los cuarzos con restricción
    a nivel de línea a una única categoría que restringa a nivel de orbamento.
  - También se probó a marcar todas las ranuras.

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
- Axiomas
  - `(enough-power-for-element ?e - element ?l - line ?a - art)`
  - `(line-active ?l - line ?a - art)`
  - `(orbament-active ?o - orbament ?a - art)`
  - `(any-active ?a - art)`
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

- Insertar un cuarzo.
- Activar todas las artes de un tipo dado.
- Activar todas las artes.
- Activar todas las artes con un solo orbamento.
- Activar todas las artes, empezando con todos los orbamentos llenos.
- Activar todas las artes, empezando con todos los orbamentos llenos y sin usar
  los mejores quarzos.

= Resultados

- Fast-downward
- Odin
- Scorpion 2023
- DecStar-2023

= Cómo ejecutar el programa y todo eso o quizás en un README.jpeg y ya.

