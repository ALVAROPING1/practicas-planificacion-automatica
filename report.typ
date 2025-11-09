#import "@preview/cetz:0.4.2": canvas, draw, tree
#import "uc3mreport.typ": conf

#show: conf.with(
  degree: "Máster en Ciencia y Tecnología Informática",
  subject: "Planificación Automática",
  year: (25, 26),
  project: "Práctica 3",
  title: [Planificación Heurística],
  group: 1,
  authors: (
    (
      name: "Álvaro",
      surname: "Guerrero Espinosa",
      nia: 100472294
    ),
    (
      name: "José Antonio",
      surname: "Verde Jiménez",
      nia: 100472221
    ),
  ),
  // professor: "Perico de los Palotes",
  toc: false,
  logo: "new",
  language: "es",
  abstract: [
    Esto es un resumen, no sé qué de lorem ipsum dolor amet
  ]
)

#show table: block.with(stroke: (y: 0.7pt))
#set table(
  row-gutter: 0.2em,   // Row separation
  stroke: (_, y) => if y == 0 { (bottom: 0.2pt) }
)

= Mundo de bloques

== Heuristic Search Planning

Para cada predicado meta, se realiza una búsqueda en anchura hacia atrás sobre
los operadores hasta encontrar una secuencia que obtenga la meta desde los
literales ciertos en el estado inicial. Aunque el algoritmo instancia todos los
operadores al inicio, para reducir el tamaño de los diagramas se dejarán
operadores parcialmente instanciados en los casos en los que cualquier posible
instanciación del operador no genera nuevos nodos. También se utilizará un
código de colores para resaltar las precondiciones de los operadores, donde el
rojo representa un predicado cierto en el estado inicial, el verde un predicado
que todavía se tiene que obtener, y el azul un predicado que no se puede
obtener, ya sea porque crearía un bucle en la búsqueda o porque no es cierto en
el estado inicial.

// Goals:
// - en-mesa(A)
// - encima(B, A)
// - encima(C, B)
//
// Initial:
// - en-mesa(C)
// - encima(B, C)
// - encima(A, B)

/// asd
/// - done (bool, none):
/// - text (content):
/// -> content
#let pred(done, name) = text(fill: if done == none {blue} else if done {olive} else {red}, name)

#let scale-to-width(body, factor: 100%) = context {
  let target = (
    page.width - page.margin.left.length - page.margin.right.length
  )
  let (width, height) = measure(body)
  scale(target / width * factor, reflow: true, body)
}

#figure(scale-to-width(
  canvas({
    import draw: *
    set-style(content: (padding: 0.5em))
    tree.tree(direction: "up",
      (pred(true, `en-mesa(A)`),
        (`DEJAR(A)`,
        (pred(true, `sujeto(A)`),
          (`QUITAR(A, B)`, [#pred(false, `encima(A, B)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)]),
          (`QUITAR(A, C)`, [#pred(none, `encima(A, C)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)]),
          (`LEVANTAR(A)`,  [#pred(none, `en-mesa(A)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)])))))
  }), factor: 45%
), caption: [Árbol para la meta `en-mesa(A)`])

#place(auto, float:true, scope:"parent", figure(scale-to-width(
  canvas({
    import draw: *
    set-style(content: (padding: 0.5em))
    tree.tree(direction: "up",
      (pred(true, `encima(B, A)`),
        (`PONER(B, A)`,
        ([#pred(true, `sujeto(B)`) \ #pred(false, `libre(A)`)],
          (`QUITAR(B, C)`,
            ([#pred(true, `libre(B)`) \ #pred(false, `encima(B, C)`) \ #pred(false, `brazo-libre`)],
              (`DEJAR(B, x)`, [#pred(none, `sujeto(B)`) \ #pred(true, `libre(x)`)]),
              (`DEJAR(B)`, pred(none, `sujeto(B)`)),
              (`QUITAR(C, B)`, [#pred(none, `encima(C, B)`) \ #pred(true, `libre(C)`) \ #pred(false, `brazo-libre`)]),
              (`QUITAR(A, B)`, [#pred(false, `encima(A, B)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)]))),
          (`QUITAR(B, A)`, [#pred(true, `libre(B)`) \ #pred(none, `encima(B, A)`) \ #pred(false, `brazo-libre`)]),
          (`LEVANTAR(B)`,  [#pred(true, `libre(B)`) \ #pred(none, `en-mesa(B)`) \ #pred(false, `brazo-libre`)])))))
  }), factor: 70%
), caption: [Árbol para la meta `encima(B, A)`]))

El coste de las metas `en-mesa(A)` y `encima(B, A)` es la cantidad de operadores
a aplicar para lograr esta meta desde el estado inicial. Como se ha encontrado
un único camino que logre esto, el coste es el mismo para $g^+$ y $g^"max"$.
Como para la meta `encima(C, B)` es necesario obtener dos predicados
independientes, hay que calcular el coste de la heurística para ambos predicados
y combinar los valores para obtener el valor final de la meta. Por último, es
necesario combinar el valor de cada meta independiente para obtener el coste de
lograr todas las metas.

#figure(align(center, table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, center),
  table.header([Predicado], $g(x)$, $g^+(x)$, $g^"max" (x)$),
  [`en-mesa(A)`], $2$, $2$, $2$,
  [`encima(B, A)`], $3$, $3$, $3$,
  [`sujeto(C)`], $3$, $3$, $3$,
  [`sujeto(B)`], $1$, $1$, $1$,
  [`encima(C, B)`], [-], $(3 + 1) + 1 = 5$, $max(3, 1) + 1 = 4$,
  [Meta], [-], $2 + 3 + 5 = 10$, $max(2, 3, 4) = 4$
)), caption: [Valores heurísticos con HSP])

== Heurística con _Fast Forward_ (FF)
_Fast Forward_ utiliza una heurística admisible basada en aplicar _GRAPHPLAN_
al mismo problema relajado del que partían las heurísticas de _Heuristic Search
Planning_. Como se eliminan los borrados, no existen casos de exclusión mutua.

Como se ve en la @fig:ff, se parte en el nivel primero (nivel 0) con los
predicados que son ciertos en el estado inicial. A continuación, se buscan
todas las acciones cuyas precondiciones estén todas en dicha lista de
predicados y que produzcan (añadidos) predicados nuevos. Y así sucesivamente
hasta que se llega al último nivel (en este caso nivel 4) en el que están todos
los predicados que pertenecen al estado final.

Finalmente se hace una búsqueda hacia atrás marcando las acciones que producían
los predicados finales. A esta lista la vamos a llamar $O$:

$ O = chevron.l O_0, O_1, O_2, O_3 chevron.r $

Donde:

- $O_0 = chevron.l "quitar(A, B)" chevron.r$
- $O_1 = chevron.l "dejar(A)", "quitar(B, C)" chevron.r$
- $O_2 = chevron.l "poner(B, A)", "levantar(C)" chevron.r$
- $O_3 = chevron.l "poner(C, B)" chevron.r$

Finalmente la heurística $h$ se computa como:

  $ h(S) = sum_(i=0)^3 |O_i| = 1 + 2 + 2 + 1 = 6 $

#let ff-predicates = (
  // Nivel 0
  ("brazo-libre",
   "en-mesa(C)",
   "encima(A, B)", "encima(B, C)",
   "libre(A)"),
  // Nivel 1
  ("brazo-libre",
   "en-mesa(C)",
   "encima(A, B)", "encima(B, C)",
   "libre(A)", "libre(B)",
   "sujeto(A)"),
  // Nivel 2
  ("brazo-libre",
   "encima(A, B)", "encima(B, C)",
   "libre(C)",
   "sujeto(A)", "en-mesa(C)","sujeto(B)",
   "en-mesa(A)",
   "libre(B)", "libre(A)",
  ),
  // Nivel 3
  ("brazo-libre", "sujeto(B)", "sujeto(C)",
   "en-mesa(A)", "en-mesa(B)", "en-mesa(C)",
   "encima(A, B)", "encima(B, C)",
   "libre(A)", "libre(B)", "libre(C)",
   "sujeto(A)", "encima(B, A)",
  ),
  // Nivel 4
  ("brazo-libre",
   "en-mesa(A)", "en-mesa(B)", "en-mesa(C)",
   "encima(A, B)", "encima(B, C)", "encima(B, A)", "encima(C, B)", "encima(C, A)", "encima(A, C)",
   "libre(A)", "libre(B)", "libre(C)",
   "sujeto(A)", "sujeto(B)", "sujeto(C)"))

#let ff-actions = (
  // Nivel 0-1
  ("quitar(A, B)" : (pre  : ("encima(A, B)", "libre(A)", "brazo-libre"),
                     post : ("libre(B)", "sujeto(A)"))),
  // Nivel 1-2
  ("quitar(B, C)" : (pre  : ("encima(B, C)", "libre(B)", "brazo-libre"),
                     post : ("libre(C)", "sujeto(B)")),
   "dejar(A)"     : (pre  : ("sujeto(A)",),
                     post : ("en-mesa(A)", "libre(A)"))),
  // Nivel 2-3
  (
   "levantar(C)"  : (pre  : ("en-mesa(C)", "libre(C)", "brazo-libre"),
                     post : ("sujeto(C)",)),
   "dejar(B)"     : (pre  : ("sujeto(B)",),
                     post : ("en-mesa(B)", "libre(B)")),
   "poner(B, A)"  : (pre  : ("sujeto(B)", "libre(A)"),
                     post : ("encima(B, A)",)),
  ),
  // Nivel 3-4
  (
    "poner(C, B)" : (pre  : ("sujeto(C)", "libre(B)"),
                     post : ("encima(C, B)",)),
    "poner(C, A)" : (pre  : ("sujeto(C)", "libre(A)"),
                     post : ("encima(C, A)",)),
    "poner(A, C)" : (pre  : ("sujeto(A)", "libre(C)"),
                     post : ("encima(A, C)",)),
  ))

#let ff-final = (
  "en-mesa(A)", "encima(B, A)", "encima(C, B)", "brazo-libre", "libre(C)",
  "poner(C, B)", "poner(B, A)", "dejar(A)", "quitar(A, B)", "levantar(C)", "quitar(B, C)",
)

#let draw-ff(width, height) = canvas({
  let space = width / (ff-predicates.len() + 2)
  let text-height = 1.0em
  let inter-space = { h(0.4em) }
  for level in range(ff-predicates.len()) {
    let x = (level + 1) * space
    let predicates = ff-predicates.at(level)
    let predicates-height = text-height * (predicates.len() + 2)
    let text-start = (height - predicates-height) / 2
    draw.line((x, 0), (x, text-start))
    draw.line((x, height), (x, height - text-start))
    draw.content((x, height + text-height), [Nivel #level])
    for p in range(predicates.len()) {
      let name = predicates.at(p)
      let color = if ff-final.contains(name) { rgb("#005ec8") } else { rgb("#000000") }
      draw.content((x, text-start + text-height * (p + 1.5)),
                   text(size : text-height, fill: color,
                        align(center)[#inter-space #name #inter-space]),
                   name : name + ":" + str(level))
    }
  }

  for a in range(ff-actions.len()) {
    let x = (a + 1.5) * space
    let text-start = 0pt
    let i = 0
    let actions = ff-actions.at(a)
    let count = actions.len()
    let actions-height = text-height * (actions.len() + 2)
    let text-start = (height - actions-height) / 2
    for (key, data) in actions {
      let name = key + ":" + str(key)
      let color = if ff-final.contains(key) { rgb("#c85e00") } else { rgb("#000000") }
      draw.content((x, text-start + text-height * (i + 1.5)),
                   text(size : text-height, fill: color,
                        align(center)[#inter-space #key #inter-space]),
                   name : name)
      for pre in data.pre {
        draw.line(pre + ":" + str(a) + ".mid-east", name + ".mid-west")
      }
      for post in data.post {
        draw.line(post + ":" + str(a + 1) + ".mid-west", name + ".mid-east")
      }
      i = i + 1
    }
  }
})

= Costes arbitrarios con FF

Como el coste de la heurística en FF es la cantidad de operadores utilizados
(coste de los operadores suponiendo coste unitario), se podría utilizar la suma
de los costes de los operadores para permitir costes arbitrarios en las
acciones. Es decir, si $O_i$ es el conjunto de operadores seleccionados en el nivel $i$ y $m$ el nivel de las metas, y el coste de la heurística de FF es:

$ h(s) = sum_(i = 0)^m |O_i| $

Se podría reemplazar esta expresión por:

$ h(s) = sum_(i = 0)^m sum_(o in O_i) "cost"(o) $

#[
  #set page(flipped: true, columns: 1)
  #set align(horizon)
  #figure(scale-to-width(
  canvas({
    import draw: *
    set-style(content: (padding: 0.5em))
    tree.tree(direction: "up",
      (pred(true, `encima(C, B)`),
        (`PONER(C, B)`,
          (pred(true, `sujeto(C)`),
            (`QUITAR(C, x)`, [#pred(true, `libre(C)`) \ #pred(none, `encima(C, x)`) \ #pred(false, `brazo-libre`)]),
            (`LEVANTAR(C)`,
              ([#pred(true, `libre(C)`) \ #pred(false, `en-mesa(C)`) \ #pred(false, `brazo-libre`)],
                (`DEJAR(C, x)`, [#pred(none, `sujeto(C)`) \ #pred(true, `libre(x)`)]),
                (`DEJAR(C)`, pred(none, `sujeto(C)`)),
                (`QUITAR(A, C)`,
                  [#pred(false, `libre(A)`) \ #pred(none, `encima(A, C)`) \ #pred(false, `brazo-libre`)]),
                (`QUITAR(B, C)`,
                  ([#pred(true, `libre(B)`) \ #pred(false, `encima(B, C)`) \ #pred(false, `brazo-libre`)],
                    (`DEJAR(B, x)`, [#pred(none, `sujeto(B)`) \ #pred(true, `libre(x)`)]),
                    (`DEJAR(B)`, pred(none, `sujeto(B)`)),
                    (`QUITAR(A, B)`, [#pred(false, `encima(A, B)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)]),
                    (`QUITAR(C, B)`, [#pred(none, `encima(C, B)`) \ #pred(true, `libre(C)`) \ #pred(false, `brazo-libre`)])))))),
          (pred(true, `libre(B)`),
            (`DEJAR(B, x)`, [#pred(none, `sujeto(B)`) \ #pred(true, `libre(x)`)]),
            (`DEJAR(B)`, pred(none, `sujeto(B)`)),
            (`QUITAR(C, B)`, [#pred(none, `encima(C, B)`) \ #pred(true, `libre(C)`) \ #pred(false, `brazo-libre`)]),
            (`QUITAR(A, B)`, [#pred(false, `encima(A, B)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)])))))
  }), factor: 140%
), caption: [Árbol para la meta `encima(C, B)`]))

  #figure(
    caption: [Fast Forward],
    draw-ff(40cm, 10cm))<fig:ff>
]


