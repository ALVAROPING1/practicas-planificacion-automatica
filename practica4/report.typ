#import "@preview/cetz:0.4.2": canvas, draw, tree
#import "uc3mreport.typ": conf

#show: conf.with(
  degree: "Máster en Ciencia y Tecnología Informática",
  subject: "Planificación Automática",
  year: (25, 26),
  project: "Práctica 4",
  title: [Planificación con FastDownward],
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
  language: "es"
)

#show table: block.with(stroke: (y: 0.7pt))
#set table(
  row-gutter: 0.2em,   // Row separation
  stroke: (_, y) => if y == 0 { (bottom: 0.2pt) }
)

= Descripción de los dominios

== Snake

Este dominio define el clásico juego de "Snake", en el que una serpiente se
mueve por un plano bidimensional y tiene que comer comida para aumentar su
puntuación, al mismo tiempo que evita obstáculos como las paredes o su propio
cuerpo. Cada vez que come comida, aumenta su longitud en 1.

Este dominio añade dos modificaciones al juego original. La primera es que la
cantidad total de comida que aparece es finita, a diferencia del juego original
en el que aparece comida hasta que la serpiente se choca con un obstáculo.
Además, se permite que haya obstáculos en las casillas, y que haya comida en
múltiples posiciones simultáneamente.

El objetivo en este dominio es comer toda la comida que aparezca.

=== Tipos

Este dominio no cuenta con ningún tipo especial

=== Predicados

// up down left right of a field
- `(ISADJACENT ?x ?y)`: Indica que dos posiciones son adjacentes.
// the last field of the snake
- `(tailsnake ?x)`: Indica que la posición contiene la cola de la serpiente.
// the first field of the snake
- `(headsnake ?x)`: Indica que la posición contiene la cabeza de la serpiente.
// pieces of the snake that are connected. from front to back
- `(nextsnake ?x ?y)`: Indica que la posición contiene el segmento de la
  serpiente a continuación del segmento en la otra posición.
// a field that is occupied by the snake or by an obstacle
- `(blocked ?x)`: Indica que una posición está ocupada, ya sea por un obstaculo
  o por la serpiente.
// next point that will spawn
- `(spawn ?x)`: Indica la posición en la que aparecerá la siguiente comida.
// point y will spawn after point x
- `(NEXTSPAWN ?x ?y)`: Indica que la comida en la posición `y` aparecerá después
  de la comida en la posición `x`.
// a field that has a point that can be collected by the snake
- `(ispoint ?x)`: Indica que la posición contiene comida.

=== Acciones

- `(:action move)`: Mueve la serpiente a una posición vacía adyacente
- `(:action move-and-eat-spawn)`: Mueve la serpiente a una posición adjacente
  con comida, aumentando la longitud de la serpiente en 1 y creando comida en la
  siguiente posición.
- `(:action move-and-eat-no-spawn)`: Mueve la serpiente a una posición
  adyacente con comida, aumentando la longitud de la serpiente en 1 pero sin
  crear más comida.

