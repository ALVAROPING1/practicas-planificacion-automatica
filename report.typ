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
  logo: "old",
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
   "en-mesa(A)", "en-mesa(C)",
   "encima(A, B)", "encima(B, C)",
   "libre(A)", "libre(B)", "libre(C)",
   "sujeto(A)", "sujeto(B)"),
  // Nivel 3
  ("brazo-libre",
   "en-mesa(A)", "en-mesa(B)", "en-mesa(C)",
   "encima(A, B)", "encima(B, C)", "encima(B, A)",
   "libre(A)", "libre(B)", "libre(C)",
   "sujeto(A)", "sujeto(B)", "sujeto(C)"),
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
  ("dejar(B)"     : (pre  : ("sujeto(B)"),
                     post : ("en-mesa(B)", "libre(B)")),
   "poner(B, A)"  : (pre  : ("sujeto(B)", "libre(A)"),
                     post : ("encima(B, A)")),
   "levantar(C)"  : (pre  : ("en-mesa(C)", "libre(C)", "brazo-libre"),
                     post : ("sujeto(B)"))),
  // Nivel 3-4
                     // TODO: poner(A, C), poner(C, A), poner(C, B)
  ())

#let ff-marks = ()

#let draw-ff(width, height, marks) = canvas({
  draw.set-style(content: (padding: 0.5em))
  let space = width / (ff-predicates.len() + 2)
  for level in range(ff-predicates.len()) {
    let x = (level + 1) * space
    let predicates = ff-predicates.at(level)
    let text-height = 1em
    let predicates-height = text-height * (predicates.len() + 2)
    let text-start = (height - predicates-height) / 2
    draw.line((x, 0), (x, text-start))
    draw.line((x, height), (x, height - text-start))
    for p in range(predicates.len()) {
      draw.content((x - space / 2, text-start + text-height * (p + 2)),
                   (x + space / 2, text-start + text-height * (p + 2)),
                   align(center)[#predicates.at(p)],
                   name : predicates.at(p) + ":" + str(p))
    }
  }

  for inter in range(ff-actions.len()) {
    let x = (inter + 1.5) * space
    draw.line((x, 0.2), (x, 0.8))
  }
})

#figure(draw-ff(30cm, 10cm, false))

== Costes arbitrarios con FF

Como el coste de la heurística en FF es la cantidad de operadores utilizados
(coste de los operadores suponiendo coste unitario), se podría utilizar la suma
de los costes de los operadores para permitir costes arbitrarios en las
acciones.
