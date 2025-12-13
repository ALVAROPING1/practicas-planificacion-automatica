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

== Tetris

Este dominio define el clásico juego de "Tetris", en el que una serie de bloques
caen desde la parte superior de la pantalla y se tienen que apilar en la parte
inferior, evitantdo que estos lleguen a la parte superior de la pantalla.

Este dominio añade varias modificaciones al juego original. La primera es que
los bloques, en vez de aparecer cada vez que se coloca el bloque anterior,
empiezan todos en la parte superior de la pantalla. La segunda modificación es
que, en vez de tener que colocar los bloques en el orden en el aparecen, se
pueden mover en cualquier orden.

El objetivo en este dominio es colocar todas las piezas en la parte inferior de
la pantalla.

=== Tipos

- `position`: Tipo base que representa una posición.
- `pieces`: Tipo base que representa un bloque.
- `one_square`, `two_straight`, y `right_l`: Tipos derivados del tipo `pieces`
  que representan las diferentes piezas que existen en el juego.

=== Predicados

- `(clear ?xy - position)`: Indica que una posición está libre.
- `(connected ?x - position ?y - position)`: Indica que dos posiciones son
- `(at_square ?element - one_square ?xy - position)`: Indica que el bloque
  cuadrado ocupa la posición dada.
- `(at_two ?element - two_straight ?xy - position ?xy2 - position)`: Indica que
  el bloque recto ocupa las dos posiciones dadas.
- `(at_right_l ?element - right_l ?xy - position ?xy2 - position ?xy3 - position)`:
  Indica que el bloque con forma de L ocupa las tres posiciones dadas.

=== Fluents

- `(total-cost)`: Establece la métrica seguida por el planificador.

=== Acciones

- `(:action move_square)`: Mueve el bloque cuadrado de una posición a otra.
- `(:action move_two)`: Mueve el bloque recto de una posición a otra, con una
  posible rotación.
- `(:action move_l_right)`: Mueve el bloque con forma de L hacia la derecha.
- `(:action move_l_left)`: Mueve el bloque con forma de L hacia la izquierda.
- `(:action move_l_up)`: Mueve el bloque con forma de L hacia arriba.
- `(:action move_l_down)`: Mueve el bloque con forma de L hacia abajo.

= Planificadores utilizados

Los planificadores utilizados son:
- *Lama-first*: resultado de la primera búsqueda del planificador LAMA de 2011.
  Esta búsqueda es satisfacible y está optimizada para encontrar soluciones
  rápidamente, aunque sin garantía de optimalidad, utilizando una búsqueda en
  escalada con costes unitarios.
- *Seq-sat-lama-2011*: planificador LAMA de 2011 satisfacible pero no óptimo.
  Usa planificación _anytime_, es decir, tras obtener una solución rápidamente,
  continua búscando mejores soluciones hasta que se agota el tiempo de búsqueda.
- *Seq-opt-fdss-1*: _portfolio_ de 4 planificadores configurado para ser óptimo.

Las principales diferencias entre estos planificadores son el equilibrio entre
el tiempo necesario para encontrar una solución y la calidad de la solución
encontrada. "Lama-first" intenta encontrar una solución rápidamente, pero esta
puede estar muy alejada del coste óptimo. En el otro extremo, "Seq-opt-fdss-1"
garantiza una solución óptima, pero puede tardar mucho en encontrarla.

"Seq-sat-lama-2011" está en un punto intermedio: intenta encontrar una solución
rápidamente, y utiliza el tiempo restante para refinarla. Aunque no garantiza
optimalidad, generalmente el resultado estará más cerca del óptimo que el
encontrado por "Lama-first", y ofrece la flexibilidad de poder parar la búsqueda
en cualquier momento.

= Resultados

#let (header, ..data) = csv("results.csv")
#let header-types = (str, str, str, int, float, x => if x == "" { none } else { int(x) }, x => if x == "" { none } else { int(x) }, x => if x == "" { none } else { int(x) });
#let data = data.map(x => header.zip(x.zip(header-types).map(x => (x.last())(x.first()))).to-dict())
#let make-key(item, keys) = {
  keys.map(key => str(item.at(key))).join("-");
}

#let group-by(data, keys) = {
  let result = (:);
  for item in data {
    let key = make-key(item, keys);
    result.insert(key, result.at(key, default: ()) + (item,));
  }
  result;
}

#let select-field(data, field) = data.map(item => item.at(field));

#let split-key(k) = {
  let (problem, ..solver) = k.split("-")
  (problem, solver.join("-"))
}

#let field-avg(data, field) = data.pairs().map(((k, v)) => (split-key(k), v.map(x => x.at(field)).sum() / v.filter(x => x != none).len()).flatten())

#let results = group-by(data, ("ProblemKind", "Solver"))
#let solved = results.pairs().map(((k, v)) => (split-key(k), v.map(x => x.at("Solved")).sum()).flatten())
#let time = field-avg(results, "Time")
#let plan-length = field-avg(results, "PlanLength")
#let plan-cost = field-avg(results, "PlanCost")
#let expanded = field-avg(results, "ExpandedNodes")

#import "@preview/cetz:0.3.2"
#import "@preview/cetz-plot:0.1.1"

#let graph(data, y-label) = {
    //[#group-by(data, (0,))]
    let solvers = ("lama-first", "seq-sat-lama-2011", "seq-opt-fdss-1")
    let plottable-data = group-by(data, (0,))
        .pairs()
        .map(((k, v)) => (
            k,
            v.sorted(key: it => solvers.position(x => x == it.at(1)))
             .map(x => x.at(2))
        ).flatten())
    cetz.canvas({
        import cetz.draw: *
        import cetz-plot: *

        // Set-up a thin axis style
        set-style(
           axes: (stroke: .5pt, tick: (stroke: .5pt)),
           legend: (stroke: none, orientation: ttb, item: (spacing: .3), scale: 80%),
        )

        chart.columnchart(
            plottable-data,
            label-key: 0,
            value-key: (1,2,3),
            mode: "clustered",
            x-label: "Planificador",
            y-label: y-label,
            labels: solvers,
            legend: "north-east",
            size: (3.5, 4.5),
            padding: 0.1em,
        )
    })
}

Se han ejecutado todos los planificadores con un límite de tiempo de 1800
segundos (30 minutos). Cada planificador se ha ejecutado en todos los problemas
de los dominios explicados anteriormente, cada uno de los cuales cuenta con 10
problemas.

En la @solved se puede ver cuántos problemas resuelve cada planificador. Como
era de esperar, "lama-first" y "seq-sat-lama-2011" son los que más problemas
resuelven, al realizar una primera búsqueda rápida.

En la @time se puede ver como "lama-first" encuentra una solución muy
rápidamente y para, mientras que los otros planificadores utilizan más tiempo
para intentar encontrar soluciones mejores. Se observa que, como
"seq-opt-fdss-1" es óptimo, puede terminar la búsqueda tras encontrar un plan
óptimo, mientras que "seq-sat-lama-2011" continua con la búsqueda intentando
mejorar la solución encontrada.

En las figuras @length[] y @cost[] se puede observar como la solución encontrada
por "lama-first" es significativamente peor que la encontrada por
"seq-opt-fdss-1", dando este último la solución óptima. "Seq-sat-lama-2011"
encuentra una solución intermedia. En algunos problemas, este planificador
encuentra una solución muy cercana a "seq-opt-fdss-1", pero en otros se queda en
un punto intermedio entre los otros dos planificadores.

#figure(
    graph(solved, "Problemas resueltos"),
    caption: "Problemas resueltos por cada planificador"
) <solved>

#figure(
    graph(time, "Tiempo medio"),
    caption: "Tiempo medio utilizado por cada planificador"
) <time>

En la figura @expanded se puede ver que "lama-first" es el planificador que
menos nodos expande, al buscar una solución rápidamente y no intentar mejorarla.
"Seq-sat-lama-2011" y "seq-opt-fdss-1" necesitan expandir muchos más estados al
intentar buscar una solución óptima o casi óptima.

#figure(
    graph(plan-length, "Longitud media"),
    caption: "Longitud media del plan encontrado por cada planificador"
) <length>

#figure(
    graph(plan-cost, "Coste medio"),
    caption: "Coste medio del plan encontrado por cada planificador"
) <cost>

#figure(
    graph(expanded, "Cantidad media de nodos expandidos"),
    caption: "Cantidad media de nodos expandidos por cada planificador"
) <expanded>

