; vim: ft=scheme
;;;; Domain
;;;;
;;;;

;;;;      .----------------------------------------------------------------.
;;;;      |                                                                |
;;;;      v     .-----> Restrict -----> Addition -----.                    |
;;;;    Action |                                       |--> Activate --> Unmark
;;;;            '----> Unrestrict ---> Subtraction ---'



(define (domain orbament-settings)
  (:requirements :typing :action-costs :derived-predicates)

  (:types
    ;; Miscellaneous
    natural  - object   ; The set of natural numbers: {0, 1, 2, ...}
    count    - object   ; The set of natural numbers: {0, 1, 2, ...}

    element  - object   ; The different elements, in total 7.
                        ; Lower elements: Earth, Water, Fire, Wind
                        ; Higher elements: Time, Space, Mirage

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
    (succ       ?x ?y - count)

    (element-count ?x - count)
    (art-count ?x - count)

    ;; ~ Amount of quartz ~
    ;; This predicate indicates the amount of quartz in the inventory.
    (inventory-count
      ?quartz - quartz
      ?n      - natural)

    ;; ~ Elemental power of quartz ~
    ;; Element`-power' predicates represent the amount of power a quartz yields
    ;; after placing it into a slot. A quartz may give power for multiple
    ;; elements at once or just for one.
    (power
      ?element - element
      ?quartz  - quartz
      ?power   - natural)

    ;; ~ Elemental value of a line  ~
    ;; Current elemental value of each line.
    (value
      ?element - element
      ?line    - line
      ?value   - natural)

   (enough-power-for-element
              ?element - element
              ?line    - line
              ?art     - art)

    ;; ~ Elemental requirements for arts ~
    ;; In order to activate an art in a line, there is an elemental requirement
    ;; for it. For instance to activate the art `Gran lágrima', you would need
    ;; 4 points for Water, 2 points for Space and 2 points for Wind in at least
    ;; one line of the orbament.
    ;;
    ;; This forces the problem to define the requirement for 

    (requirement
      ?element - element
      ?art     - art
      ?value   - natural)

    (active ?line - line ?art - art)

    (contains-line ?orbament - orbament ?line - line)
    (contains-slot ?orbament - orbament ?slot - slot)
    (contains-quartz ?orbament - orbament ?quartz - quartz)
    (connected-line-count ?slot - slot)

    (connects ?line - line ?slot - slot)
    (filled ?slot - slot)
    (belongs ?quartz - quartz ?category - category)
    (orbament-wide ?category - category)
    (restricted ?o - limited ?category - category)

    ;; ~ State machine ~ ;;
    (action-state)

    (addition-state)
    (restrict-state)
    (activation-state)
    (unmark-state)
    (unrestrict-state)
    (deletion-state)
    (subtraction-state)

    (quartz-to-be-modified
      ?quartz - quartz)
    (category-to-be-modified
      ?category - category)
    (slot-to-be-modified
      ?slot - slot)
    (orbament-to-be-modified
      ?orbament - orbament)

    (modified
      ?element - element
      ?line - line)
    (modified-count
      ?x - count)

    (to-be-activated
      ?line - line)
    (earth-added ?line - line)
    (water-added ?line - line)
    (fire-added ?line - line)
    (wind-added ?line - line)
    (time-added ?line - line)
    (space-added ?line - line)
    (mirage-added ?line - line)

    (marked-count ?x - count)
    (marked ?art - art)

)

  (:functions (total-cost) - number)

  ;;; Insertion

  (:action insert
    :parameters (?quartz     - quartz
                 ?category   - category
                 ?slot       - slot
                 ?orbament   - orbament
                 ?count      - natural
                 ?next-count - natural)
    ;; TODO: Add quartz elemental restriction
    :precondition (and (action-state)
                       (contains-slot ?orbament ?slot)
                       (not (filled ?slot))
                       (not (contains-quartz ?orbament ?quartz))
                       (belongs ?quartz ?category)
                       ;; Check the amount in the inventory
                       (inventory-count ?quartz ?count)
                       (less-than n0 ?count)    ; ?count > 0
                       (addition n1 ?next-count ?count)
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
                 (quartz-to-be-modified ?quartz)
                 (category-to-be-modified ?category)
                 (slot-to-be-modified ?slot)
                 (orbament-to-be-modified ?orbament)
                 (contains-quartz ?orbament ?quartz)
                 (not (inventory-count ?quartz ?count))
                 (inventory-count ?quartz ?next-count)
                 (increase (total-cost) 1)
                 (not (action-state))
                 (restrict-state)))

  ;;; Restrict

  (:action restrict-orbament
    ;; This action is used to make sure that if there is an orbament-wide
    ;; restriction category that is to be applied to the orbament by the quartz
    ;; is done.
    :parameters (?category - category
                 ?orbament - orbament)
    :precondition (and (restrict-state)
                       (category-to-be-modified ?category)
                       (orbament-to-be-modified ?orbament)
                       (orbament-wide ?category)
                       (not (restricted ?orbament ?category)))
    :effect (restricted ?orbament ?category)) ; If not restricted, restrict it

  (:action restrict-line
    ;; This action is to make sure all lines are marked in the event of placing
    ;; a quartz with a line-wide restriction (such as blade or shield).
    :parameters (?category - category
                 ?slot     - slot
                 ?line     - line)
    :precondition (and (restrict-state)
                       (category-to-be-modified ?category)
                       (slot-to-be-modified ?slot)
                       (connects ?line ?slot)
                       (not (restricted ?line ?category)))
    :effect (restricted ?line ?category))

  (:action finish-restrict
    ;; Finish restrictions if the restriction is applied where it has to be
    ;; applied. And then pass to the next step: Addition
    :parameters (?quartz   - quartz
                 ?category - category
                 ?slot     - slot
                 ?orbament - orbament)
    :precondition (and (restrict-state)
                       (quartz-to-be-modified ?quartz)
                       (category-to-be-modified ?category)
                       (slot-to-be-modified ?slot)
                       (orbament-to-be-modified ?orbament)
                       ;; If the category is orbament wide, then check it has
                       ;; been applied.
                       (imply (orbament-wide ?category)
                              (restricted ?orbament ?category))
                       ;; Otherwise, check if it has been applied to every line
                       (imply (not (orbament-wide ?category))
                              (forall (?line - line)
                                (imply (connects ?line ?slot)
                                  (restricted ?line ?category)))))
    :effect (and (not (orbament-to-be-modified ?orbament))
                 (not (category-to-be-modified ?category))
                 ;; We can forget about orbaments and categories for now.
                 ;; We still need the `?slot' and the `?quartz' for addition.
                 (not (restrict-state))
                 (addition-state)))

  ;;; Addition

  (:action element-addition
    :parameters (?line    - line
                 ?slot    - slot
                 ?quartz  - quartz
                 ?element - element
                 ?old     - natural
                 ?power   - natural
                 ?new     - natural)
    :precondition (and (addition-state)
                       (slot-to-be-modified ?slot)
                       (quartz-to-be-modified ?quartz)
                       (connects ?line ?slot)
                       (not (modified ?element ?line))
                       (value ?element ?line ?old)
                       (power ?element ?quartz ?power)
                       (addition ?old ?power ?new))
    :effect (and (modified ?element ?line)
                 (not (value ?element ?line ?old))
                 (value ?element ?line ?new)))

  (:action finish-line-addition
    :parameters (?line - line
                 ?slot - slot)
    :precondition (and (addition-state)
                       (slot-to-be-modified ?slot)
                       (connects ?line ?slot)
                       (not (to-be-activated ?line))
                       (forall (?element - element)
                         (modified ?element ?line)))
    :effect (to-be-activated ?line))

  (:action finish-addition
    :parameters (?quartz - quartz
                 ?slot   - slot)
    :precondition (and (addition-state)
                       (quartz-to-be-modified ?quartz)
                       (slot-to-be-modified ?slot)
                       ;; All lines that connect the slot where the quartz has
                       ;; been inserted have been added to the elemental value
                       ;; of the quartz.
                       (forall (?line - line)
                         (imply (connects ?line ?slot)
                                (to-be-activated ?line))))
    :effect (and (not (quartz-to-be-modified ?quartz))
                 (not (slot-to-be-modified ?slot))
                 (not (addition-state))
                 (unmark-state)))

  ; Unmarking

  (:action unmark-element
    :parameters (?line    - line
                ?element - element)
    :precondition (and (unmark-state)
                       (modified ?element ?line))
    :effect (not (modified ?element ?line)))

  (:action unmark-line
    :parameters (?line - line)
    :precondition (and (unmark-state)
                       (to-be-activated ?line)
                       (forall (?element - element)
                         (not (modified ?element ?line))))
    :effect (not (to-be-activated ?line)))

  (:action finish-unmark
    :precondition (and (unmark-state)
                       (forall (?line - line)
                         (not (to-be-activated ?line))))
    :effect (and (not (unmark-state))
                 (action-state)))


  ;;; Activation

; (:action activate
;   :parameters (?line  - line
;                ?art   - art
;                ?count - count
;                ?succ  - count)

;   :precondition (and (activation-state)
;                      (to-be-activated ?line)
;                      ;; Mark the art as viewed
;                      (not (marked art))
;                      (marked-count ?count)
;                      (succ ?count ?succ)
;                      ;; When for all elements value >= requirement
;                      (forall (?element - element)
;                        (forall (?v - natural)
;                          (imply (value ?element ?line ?v)
;                                 (forall (?r - natural)
;                                   (imply (requirement ?element ?art ?r)
;                                          (not (less-than ?v ?r))))))))
;   :effect (and (active ?line ?art)
;                ;; Increment the marked count in 1
;                (marked ?art)   ; Art is activated
;                (not (marked-count ?count))
;                (marked-count ?succ)))

; (:action deactivate
;   :parameters (?line  - line
;                ?art   - art
;                ?count - count
;                ?succ  - count)

;   :precondition (and (activation-state)
;                      (to-be-activated ?line)
;                      ;; Mark the art as viewed
;                      (not (marked art))
;                      (marked-count ?count)
;                      (succ ?count ?succ)
;                      ;; When for some elements value < requirement
;                      (forall (?element - element)
;                        (forall (?v - natural)
;                          (imply (value ?element ?line ?v)
;                                 (exists (?r - natural)
;                                   (imply (requirement ?element ?art ?r)
;                                          (less-than ?v ?r)))))))
;   :effect (and (not (active ?line ?art))   ; Art is deactivated
;                ;; Increment the marked count in 1
;                (marked ?art)
;                (not (marked-count ?count))
;                (marked-count ?succ)))

; (:action finish-activation  ;; 5 rules
;   :parameters (?line - line)
;   :precondition (and (activation-state)
;                      (forall (?art - art)
;                        (marked ?art)))
;   :effect (and (not (to-be-activated ?line))
;                (not (activation-state))
;                (unmark-state)))

; ;;; Umarking

; (:action unmark
;   :parameters (?art   - art
;                ?count - count
;                ?pred  - count)
;   :precondition (and (unmark-state)
;                      (marked ?art)
;                      (marked-count ?count)
;                      (succ ?pred ?count))
;   :effect (and (not (marked ?art))
;                (not (marked-count ?count))
;                (marked-count ?pred)))

; (:action unmark-line
;   :parameters (?line    - line
;                ?element - element)
;   :precondition (and (unmark-state)
;                      (modified ?element ?line))
;   :effect (not (modified ?element ?line)))

; (:action finish-unmarking
;   :precondition (and (unmark-state)
;                      (marked-count c0))
;                      ;; (forall (?element - element)
;                      ;;   (forall (?line - line)
;                      ;;     (not (modified ?element ?line)))))
;   :effect (and (not (unmark-state))
;                (action-state)))

; ;;; Removal

; ;;; Subtraction

  (:derived (enough-power-for-element
              ?element - element
              ?line    - line
              ?art     - art)
    (exists (?v - natural)
      (exists (?r - natural)
        (and (value ?element ?line ?v)
             (requirement ?element ?art ?r)
             (not (less-than ?v ?r))))))

  (:derived (active
              ?line - line
              ?art  - art)
    (and (action-state)
         (forall (?element - element)
           (enough-power-for-element ?element ?line ?art))))

)
