#import "@preview/cetz:0.4.2": canvas, draw, tree
#import "uc3mreport.typ": conf

#show: conf.with(
  degree: "Máster en Ciencia y Tecnología Informática",
  subject: "Planificación Automática",
  year: (25, 26),
  project: "Práctica 3",
  title: "Planificación Heurística",
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
)

#show table: block.with(stroke: (y: 0.7pt))
#set table(
  row-gutter: 0.2em,   // Row separation
  stroke: (_, y) => if y == 0 { (bottom: 0.2pt) }
)

= Mundo de bloques

== Heuristic Search Planning

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

/// text (content):
/// -> content
#let op(name) = text(fill: blue, name)

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
        (op(`DEJAR(A)`),
        (pred(true, `sujeto(A)`),
          (op(`QUITAR(A, B)`), [#pred(false, `encima(A, B)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)]),
          (op(`QUITAR(A, C)`), [#pred(none, `encima(A, C)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)]),
          (op(`LEVANTAR(A)`),  [#pred(none, `en-mesa(A)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)])))))
  }), factor: 70%
), caption: [Árbol para la meta `en-mesa(A)`])

#figure(scale-to-width(
  canvas({
    import draw: *
    set-style(content: (padding: 0.5em))
    tree.tree(direction: "up",
      (pred(true, `encima(B, A)`),
        (op(`PONER(B, A)`),
        ([#pred(true, `sujeto(B)`) \ #pred(false, `libre(A)`)],
          (op(`QUITAR(B, C)`),
            ([#pred(true, `libre(B)`) \ #pred(false, `encima(B, C)`) \ #pred(false, `brazo-libre`)],
              (op(`DEJAR(B, x)`), [#pred(none, `sujeto(B)`) \ #pred(true, `libre(x)`)]),
              (op(`DEJAR(B)`), pred(none, `sujeto(B)`)),
              (op(`QUITAR(C, B)`), [#pred(none, `encima(C, B)`) \ #pred(true, `libre(C)`) \ #pred(false, `brazo-libre`)]),
              (op(`QUITAR(A, B)`), [#pred(false, `encima(A, B)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)]))),
          (op(`QUITAR(B, A)`), [#pred(true, `libre(B)`) \ #pred(none, `encima(B, A)`) \ #pred(false, `brazo-libre`)]),
          (op(`LEVANTAR(B)`),  [#pred(true, `libre(B)`) \ #pred(none, `en-mesa(B)`) \ #pred(false, `brazo-libre`)])))))
  }), factor: 70%
), caption: [Árbol para la meta `encima(B, A)`])

#figure(scale-to-width(
  canvas({
    import draw: *
    set-style(content: (padding: 0.5em))
    tree.tree(direction: "up",
      (pred(true, `encima(C, B)`),
        (op(`PONER(C, B)`),
          (pred(true, `sujeto(C)`),
            (op(`QUITAR(C, x)`), [#pred(true, `libre(C)`) \ #pred(none, `encima(C, x)`) \ #pred(false, `brazo-libre`)]),
            (op(`LEVANTAR(C)`), 
              ([#pred(true, `libre(C)`) \ #pred(false, `en-mesa(C)`) \ #pred(false, `brazo-libre`)],
                (op(`DEJAR(C, x)`), [#pred(none, `sujeto(C)`) \ #pred(true, `libre(x)`)]),
                (op(`DEJAR(C)`), pred(none, `sujeto(C)`)),
                (op(`QUITAR(A, C)`),
                  [#pred(false, `libre(A)`) \ #pred(none, `encima(A, C)`) \ #pred(false, `brazo-libre`)]),
                (op(`QUITAR(B, C)`),
                  ([#pred(true, `libre(B)`) \ #pred(false, `encima(B, C)`) \ #pred(false, `brazo-libre`)],
                    (op(`DEJAR(B, x)`), [#pred(none, `sujeto(B)`) \ #pred(true, `libre(x)`)]),
                    (op(`DEJAR(B)`), pred(none, `sujeto(B)`)),
                    (op(`QUITAR(A, B)`), [#pred(false, `encima(A, B)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)]),
                    (op(`QUITAR(C, B)`), [#pred(none, `encima(C, B)`) \ #pred(true, `libre(C)`) \ #pred(false, `brazo-libre`)])))))),
          (pred(true, `libre(B)`),
            (op(`DEJAR(B, x)`), [#pred(none, `sujeto(B)`) \ #pred(true, `libre(x)`)]),
            (op(`DEJAR(B)`), pred(none, `sujeto(B)`)),
            (op(`QUITAR(C, B)`), [#pred(none, `encima(C, B)`) \ #pred(true, `libre(C)`) \ #pred(false, `brazo-libre`)]),
            (op(`QUITAR(A, B)`), [#pred(false, `encima(A, B)`) \ #pred(false, `libre(A)`) \ #pred(false, `brazo-libre`)])))))
  }), factor: 70%
), caption: [Árbol para la meta `encima(C, B)`])

#figure(align(center, table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, center),
  table.header([Predicado], $g(x)$, $g^+(x)$, $g^"max" (x)$),
  [`en-mesa(A)`], $2$, $2$, $2$,
  [`encima(B, A)`], $3$, $3$, $3$,
  [`sujeto(C)`], $3$, $3$, $3$,
  [`sujeto(B)`], $1$, $1$, $1$,
  [`encima(C, B)`], [-], $4$, $3$,
  [Meta], [-], $2 + 3 + 4 = 9$, $3$
)), caption: [Valores heurísticos con HSP])

== Heurística con FF
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

#[
  #set page(flipped: true)
  #set align(horizon)
  #figure(
    caption: [Fast Forward],
    draw-ff(40cm, 10cm))<fig:ff>
]

== Costes arbitrarios con FF

Como el coste de la heurística en FF es la cantidad de operadores utilizados
(coste de los operadores suponiendo coste unitario), se podría utilizar la suma
de los costes de los operadores para permitir costes arbitrarios en las
acciones.
