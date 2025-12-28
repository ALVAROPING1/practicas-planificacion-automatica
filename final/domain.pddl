; vim: ft=scheme
;;;; Domain
;;;;
;;;;
;;;; State machine:
;;;;
;;;;     .------------------------------------------------------------.
;;;;     v                                                            |
;;;;  Action ----> Insertion ----> Addition ----> Activation -------->|
;;;;           |-> Deletion ----> Subtraction ----> Deactivation ---->|
;;;;           '------------------------------------------------------'
;;;;
;;;; ~ Action -> Insertion ~
;;;; When a quartz is inserted the state changes to: `insertion-state' and the
;;;; predicate `(to-be-inserted ?quartz ?category ?slot ?orbament)' is true.
;;;; This is exectued when the `insert' action is done.
;;;;
;;;; ~ Insertion -> Addition ~
;;;; While there are lines to be inserted `(to-be-activated ?line)' is
;;;; set for all the lines that are to activate a quartz. This is executed when
;;;; `add' action is done.



(define (domain orbament-settings)
  (:requirements :typing :action-costs)

  (:types
    ;; Miscellaneous
    natural  - object   ; The set of natural numbers: {0, 1, 2, ...}

    ;; Quartz & Arts
    quartz   - object   ; Quartz that can be inserted into slots.
                        ; Quartz are associated with a single element and a
                        ; a category.
                        ; Each quartz adds a power level to a line for each
                        ; of the 7 possible elements.

    art      - object   ; Arts are unlocked after obtaining certain elemental
                        ; value for a line in an orbament.

    category - object   ; There are line-wide and orbament-wide restrictions.
                        ; You cannot place two `blade' quartz inside the same
                        ; line, but can on different lines in the same orbament.
                        ; You cannot place, for instance, a `Defensa 1' and
                        ; `Defensa 2' in the same orbament. There is a class-
                        ; wide restriction.

    ;; Orbaments
    limited  - object   ; Orbaments and lines are limited in the sense that
                        ; there are certain restrictions

    orbament - limited  ; An orbament is a set of slots connected by lines
                        ; associated with a character in the game.

    slot     - object   ; A slot is a place in the orbament where a quartz can
                        ; be placed. There are slots with elemental
                        ; restrictions. So if a slot has an `Earth'
                        ; restriction, you cannot place a non-earth element in
                        ; it.

    line     - limited) ; Lines connect slots inside an orbament. There is an
                        ; element level associated with each line, which is
                        ; equal to the sum of all the elemental levels of the
                        ; quartz placed in slots connected by such a line.
                        ; For instance a line with quartz: `Defensa 1',
                        ; `Ataque 2' y `Mente 3', would have elemental power
                        ; 1 for Earth, 2 for Fire and 3 for Water, and 0 for
                        ; the rest.


  ;;;                            ~ Predicates ~                             ;;;

  (:predicates

    ;; ~ Natural number operations ~
    (addition   ?lhs ?rhs ?res - natural)
    (less-than  ?lhs ?rhs - natural)

    ;; ~ Amount of quartz ~
    ;; This predicate indicates the amount of quartz in the inventory.
    (count
      ?quartz - quartz
      ?n      - natural)

    ;; ~ Elemental power of quartz ~
    ;; Element`-power' predicates represent the amount of power a quartz yields
    ;; after placing it into a slot. A quartz may give power for multiple
    ;; elements at once or just for one.
    (earth-power
      ?quartz - quartz
      ?value  - natural)
    (water-power
      ?quartz - quartz
      ?value  - natural)
    (fire-power
      ?quartz - quartz
      ?value  - natural)
    (wind-power
      ?quartz - quartz
      ?value  - natural)
    (time-power
      ?quartz - quartz
      ?value  - natural)
    (space-power
      ?quartz - quartz
      ?value  - natural)
    (mirage-power
      ?quartz - quartz
      ?value  - natural)

    ;; ~ Elemental value of a line  ~
    ;; Current elemental value of each line.
    (earth-value
      ?line  - line
      ?value - natural)
    (water-value
      ?line  - line
      ?value - natural)
    (fire-value
      ?line  - line
      ?value - natural)
    (wind-value
      ?line  - line
      ?value - natural)
    (time-value
      ?line  - line
      ?value - natural)
    (space-value
      ?line  - line
      ?value - natural)
    (mirage-value
      ?line  - line
      ?value - natural)

    ;; ~ Elemental requirements for arts ~
    ;; In order to activate an art in a line, there is an elemental requirement
    ;; for it. For instance to activate the art `Gran lágrima', you would need
    ;; 4 points for Water, 2 points for Space and 2 points for Wind in at least
    ;; one line of the orbament.
    ;;
    ;; This forces the problem to define the requirement for 

    (earth-requirement
      ?art   - art
      ?value - natural)
    (water-requirement
      ?art   - art
      ?value - natural)
    (fire-requirement
      ?art   - art
      ?value - natural)
    (wind-requirement
      ?art   - art
      ?value - natural)
    (time-requirement
      ?art   - art
      ?value - natural)
    (space-requirement
      ?art   - art
      ?value - natural)
    (mirage-requirement
      ?art   - art
      ?value - natural)

    (active ?line - line ?art - art)

    (contains-line ?orbament - orbament ?line - line)
    (contains-slot ?orbament - orbament ?slot - slot)
    (connects ?line - line ?slot - slot)
    (filled ?slot - slot)
    (belongs ?quartz - quartz ?category - category)
    (orbament-wide ?category - category)
    (restricted ?o - limited ?category - category)

    ;; ~ State machine ~ ;;
    (action-state)

    (addition-state)
    (to-be-inserted ?x - object)

    (activation-state)
    (to-be-activated
      ?line - line)
    (earth-added ?line - line)
    (water-added ?line - line)
    (fire-added ?line - line)
    (wind-added ?line - line)
    (time-added ?line - line)
    (space-added ?line - line)
    (mirage-added ?line - line)

    (marked ?art - art)
    (unmark-state)

    (deletion-state)
    (subtraction-state)
)

  (:functions (total-cost) - number)

  ;;; Insertion

  (:action insert ;; 36 rules
    :parameters (?quartz   - quartz
                 ?category - category
                 ?slot     - slot
                 ?orbament - orbament)
    ;; TODO: Add quartz elemental restriction
    :precondition (and (action-state)
                       (contains-slot ?orbament ?slot)
                       (not (filled ?slot))
                       ;; If the quartz has an orbament-wide restriction, then
                       ;; check there is no other quartz with the same
                       ;; restriction in the same orbament.
                       (imply (orbament-wide ?category)
                              (not (restricted ?orbament ?category)))
                       ;; Otherwise, check that there is no line that connects
                       ;; the slot which has a line-wide restriction.
                       (imply (not (orbament-wide ?category))
                              (forall (?line - line)
                                (imply (connects ?line ?slot)
                                       (not (restricted ?line ?slot))))))
    :effect (and (filled ?slot)
                 (to-be-inserted ?quartz)
                 (to-be-inserted ?category)
                 (to-be-inserted ?slot)
                 (to-be-inserted ?orbament)
                 (not (action-state))
                 (addition-state)))

  ;;; Addition

  (:action restrict-orbament  ;; 6 rules
    :parameters (?category - category
                 ?orbament - orbament)
    :precondition (and (addition-state)
                       (to-be-inserted ?category)
                       (to-be-inserted ?orbament)
                       (orbament-wide category)
                       (not (restricted ?orbament ?category)))
    :effect (restricted ?orbament ?category))

  (:action restrict-line   ;; 9 rules
    :parameters (?category - category
                 ?slot     - slot
                 ?line     - line)
    :precondition (and (addition-state)
                       (to-be-inserted ?category)
                       (to-be-inserted ?slot)
                       (connects ?line ?slot)
                       (not (restricted ?line ?category)))
    :effect (restricted ?line ?category))

  (:action earth-addition ;; 14 rules
    :parameters (?line   - line
                 ?slot   - slot
                 ?quartz - quartz
                 ?old    - natural
                 ?power  - natural
                 ?new    - natural)
    :precondition (and (addition-state)
                       (to-be-inserted ?slot)
                       (to-be-inserted ?quartz)
                       (connects ?line ?slot)
                       (not (to-be-activated ?line))
                       (not (earth-added ?line))
                       (earth-value ?line ?old)
                       (earth-power ?quartz ?power)
                       (addition ?old ?power ?new))
    :effect (and (earth-added ?line)
                 (not (earth-value ?line ?old))
                 (earth-value ?line ?new)))

  (:action mark-for-activation
    :parameters (?line - line)
    :precondition (and (addition-state)
                       (not (to-be-activated ?line))
                       (earth-added ?line)
                       (water-added ?line)
                       (fire-added ?line)
                       (wind-added ?line)
                       (space-added ?line)
                       (time-added ?line)
                       (mirage-added ?line))
    :effect (and (to-be-activated ?line)
                 (not (earth-added ?line))
                 (not (water-added ?line))
                 (not (fire-added ?line))
                 (not (wind-added ?line))
                 (not (space-added ?line))
                 (not (time-added ?line))
                 (not (mirage-added ?line))))

; (:action addition  ;; 51 rules
;   :parameters (?quartz   - quartz
;                ?category - category
;                ?slot     - slot
;                ?line     - line
;                ?orbament - orbament

;                ?old-earth-value  - natural
;                ?old-water-value  - natural
;                ?old-fire-value   - natural
;                ?old-wind-value   - natural
;                ?old-time-value   - natural
;                ?old-space-value  - natural
;                ?old-mirage-value - natural

;                ?new-earth-value  - natural
;                ?new-water-value  - natural
;                ?new-fire-value   - natural
;                ?new-wind-value   - natural
;                ?new-time-value   - natural
;                ?new-space-value  - natural
;                ?new-mirage-value - natural

;                ?earth-power  - natural
;                ?water-power  - natural
;                ?fire-power   - natural
;                ?wind-power   - natural
;                ?time-power   - natural
;                ?space-power  - natural
;                ?mirage-power - natural)

;   :precondition (and (addition-state)
;                      (to-be-inserted ?quartz ?category ?slot ?orbament)
;                      (contains-line ?orbament ?line)
;                      (connects ?line ?slot)
;                      (not (to-be-activated ?line))

;                      (earth-power  ?quartz ?earth-power)
;                      (water-power  ?quartz ?water-power)
;                      (fire-power   ?quartz ?fire-power)
;                      (wind-power   ?quartz ?wind-power)
;                      (time-power   ?quartz ?time-power)
;                      (space-power  ?quartz ?space-power)
;                      (mirage-power ?quartz ?mirage-power)

;                      (earth-value  ?line ?old-earth-value)
;                      (water-value  ?line ?old-water-value)
;                      (fire-value   ?line ?old-fire-value)
;                      (wind-value   ?line ?old-wind-value)
;                      (time-value   ?line ?old-time-value)
;                      (space-value  ?line ?old-space-value)
;                      (mirage-value ?line ?old-mirage-value))

;   :effect (and (to-be-activated ?line)

;                (not (earth-value  ?line ?old-earth-value))
;                (not (water-value  ?line ?old-water-value))
;                (not (fire-value   ?line ?old-fire-value))
;                (not (wind-value   ?line ?old-wind-value))
;                (not (time-value   ?line ?old-time-value))
;                (not (space-value  ?line ?old-space-value))
;                (not (mirage-value ?line ?old-mirage-value))

;                (earth-value  ?line ?new-earth-value)
;                (water-value  ?line ?new-water-value)
;                (fire-value   ?line ?new-fire-value)
;                (wind-value   ?line ?new-wind-value)
;                (time-value   ?line ?new-time-value)
;                (space-value  ?line ?new-space-value)
;                (mirage-value ?orbament ?new-mirage-value)))

  (:action finish-addition    ;; 36 rules
    :parameters (?quartz   - quartz
                 ?category - category
                 ?slot     - slot
                 ?orbament - orbament)
    :precondition (and (addition-state)
                       (to-be-inserted ?quartz)
                       (to-be-inserted ?category)
                       (to-be-inserted ?slot)
                       (to-be-inserted ?orbament)
                       ;; All lines that connect the slot where the quartz has
                       ;; been inserted have been added to the elemental value
                       ;; of the quartz.
                       (forall (?line - line)
                         (imply (connects ?line ?slot)
                                (to-be-activated ?line)))
                       ;; If the category is orbament wide, then check it has
                       ;; been applied.
                       (imply (orbament-wide ?category)
                              (restricted ?orbament ?category))
                       ;; Otherwise, check if it has been applied to every line
                       (imply (not (orbament-wide ?category))
                              (forall (?line - line)
                                (imply (connects ?line ?slot)
                                  (restricted ?line ?category)))))
    :effect (and (not (to-be-inserted ?quartz))
                 (not (to-be-inserted ?category))
                 (not (to-be-inserted ?slot))
                 (not (to-be-inserted ?orbament))
                 (not (addition-state))
                 (activation-state)))

  ;;; Activation

  (:action activate  ;; 32 rules
    :parameters (?line - line
                 ?art  - art

                 ?earth-value  - natural
                 ?water-value  - natural
                 ?fire-value   - natural
                 ?wind-value   - natural
                 ?time-value   - natural
                 ?space-value  - natural
                 ?mirage-value - natural

                 ?earth-requirement  - natural
                 ?water-requirement  - natural
                 ?fire-requirement   - natural
                 ?wind-requirement   - natural
                 ?time-requirement   - natural
                 ?space-requirement  - natural
                 ?mirage-requirement - natural)

    :precondition (and (activation-state)
                       (to-be-activated ?line)

                       (not (marked art))

                       (earth-value  ?line ?earth-value)
                       (water-value  ?line ?water-value)
                       (fire-value   ?line ?fire-value)
                       (wind-value   ?line ?wind-value)
                       (time-value   ?line ?time-value)
                       (space-value  ?line ?space-value)
                       (mirage-value ?line ?mirage-value)

                       (earth-requirement  ?art ?earth-requirement)
                       (water-requirement  ?art ?water-requirement)
                       (fire-requirement   ?art ?fire-requirement)
                       (wind-requirement   ?art ?wind-requirement)
                       (time-requirement   ?art ?time-requirement)
                       (space-requirement  ?art ?space-requirement)
                       (mirage-requirement ?art ?mirage-requirement)

                       (not (less-than ?earth-value ?earth-requirement))
                       (not (less-than ?water-value ?water-requirement))
                       (not (less-than ?fire-value ?fire-requirement))
                       (not (less-than ?wind-value ?wind-requirement))
                       (not (less-than ?time-value ?time-requirement))
                       (not (less-than ?space-value ?space-requirement))
                       (not (less-than ?mirage-value ?mirage-requirement)))

    :effect (and (active ?line ?art)
                 (marked ?art)))

  (:action deactivate   ;; 39 rules
    :parameters (?line - line
                 ?art  - art

                 ?earth-value  - natural
                 ?water-value  - natural
                 ?fire-value   - natural
                 ?wind-value   - natural
                 ?time-value   - natural
                 ?space-value  - natural
                 ?mirage-value - natural

                 ?earth-requirement  - natural
                 ?water-requirement  - natural
                 ?fire-requirement   - natural
                 ?wind-requirement   - natural
                 ?time-requirement   - natural
                 ?space-requirement  - natural
                 ?mirage-requirement - natural)

    :precondition (and (activation-state)
                       (to-be-activated ?line)

                       (not (marked art))

                       (earth-value  ?line ?earth-value)
                       (water-value  ?line ?water-value)
                       (fire-value   ?line ?fire-value)
                       (wind-value   ?line ?wind-value)
                       (time-value   ?line ?time-value)
                       (space-value  ?line ?space-value)
                       (mirage-value ?line ?mirage-value)

                       (earth-requirement  ?art ?earth-requirement)
                       (water-requirement  ?art ?water-requirement)
                       (fire-requirement   ?art ?fire-requirement)
                       (wind-requirement   ?art ?wind-requirement)
                       (time-requirement   ?art ?time-requirement)
                       (space-requirement  ?art ?space-requirement)
                       (mirage-requirement ?art ?mirage-requirement)

                       (less-than ?earth-value ?earth-requirement)
                       (less-than ?water-value ?water-requirement)
                       (less-than ?fire-value ?fire-requirement)
                       (less-than ?wind-value ?wind-requirement)
                       (less-than ?time-value ?time-requirement)
                       (less-than ?space-value ?space-requirement)
                       (less-than ?mirage-value ?mirage-requirement))

    :effect (and (not (active ?line ?art))
                 (marked ?art)))

  (:action finish-activation  ;; 5 rules
    :parameters (?line - line)
    :precondition (and (activation-state)
                       (forall (?art - art)
                         (marked ?art)))
    :effect (and (not (to-be-activated ?line))
                 (not (activation-state))
                 (unmark-state)))

  ;;; Umarking

  (:action unmark    ;; 2 rules
    :parameters (?art - art)
    :precondition (and (unmark-state)
                       (marked ?art))
    :effect (not (marked ?art)))

  (:action finish-unmarking   ;; 2 rules
    :precondition (unmark-state)
    :effect (and (not (unmark-state))
                 (action-state)))

  ;;; Subtraction

  (:action increment
    :parameters (?quartz - quartz
                 ?value  - natural
                 ?next   - natural)
    :precondition (and (earth-power ?quartz ?value)
                       (addition ?value n1 ?next))
    :effect (and (not (earth-power ?quartz ?value))
                 (earth-power ?quartz ?next)
                 (increase (total-cost) 10)))

)
