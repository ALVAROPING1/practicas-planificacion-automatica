;;;;=======================================================================;;;;
;;;; Authors:                                                              ;;;;
;;;;  Álvaro Guerrero Espinosa (100472294)                                 ;;;;
;;;;  José Antonio Verde Jiménez (100472221)                               ;;;;
;;;;                                                                       ;;;;
;;;; Description:                                                          ;;;;
;;;;  This file contains the description for the.                          ;;;;
;;;;---------------------------------------------------------------------- ;;;;


(define (domain orbament-settings)
  (:requirements :typing :action-costs :derived-predicates)

  (:types
    ;; Miscellaneous
    natural  - object   ; The set of natural numbers: {0, 1, 2, ...}

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
    limited  - object   ; Orbaments and losts are limited in the sense that
                        ; there are certain restrictions

    orbament - limited  ; An orbament is a set of slots connected by lines
                        ; associated with a character in the game.

    slot     - object   ; A slot is a place in the orbament where a quartz can
                        ; be placed. There are slots with elemental
                        ; restrictions. So if a slot has an `Earth'
                        ; restriction, you cannot place a non-earth element in
                        ; it.

    line     - object)  ; Lines connect slots inside an orbament. There is an
                        ; element level associated with each line, which is
                        ; equal to the sum of all the elemental levels of the
                        ; quartz placed in slots connected by such a line.
                        ; For instance a line with quartz: `Defensa 1',
                        ; `Ataque 2' y `Mente 3', would have elemental power
                        ; 1 for Earth, 2 for Fire and 3 for Water, and 0 for
                        ; the rest.


  ;;;                            ~ Predicates ~                             ;;;

  (:predicates

    ;;;  ~ Relation predicates ~  ;;;

    ;; ~ Natural number operations ~
    (addition
      ?lhs - natural
      ?rhs - natural
      ?res - natural)

    (less-than
      ?lhs - natural
      ?rhs - natural)

    ;; ~ Amount of quartz ~
    ;; This predicate indicates the amount of quartz in the inventory.
    (inventory-count
      ?quartz - quartz
      ?n      - natural)

    ;; ~ Universe ~

    (power
      ?element - element
      ?quartz  - quartz
      ?power   - natural)

    (belongs
      ?quartz   - quartz
      ?category - category)

    (requirement
      ?element - element
      ?art     - art
      ?value   - natural)

    (contains-slot
      ?orbament - orbament
      ?slot     - slot)

    (contains-line
      ?orbament - orbament
      ?line     - line)

    (orbament-wide
      ?category - category)

    (connects
      ?line - line
      ?slot - slot)

    ;; ~ Dynamic properties ~

    (value
      ?element - element
      ?line    - line
      ?value   - natural)

    (contains-quartz
      ?slot   - slot
      ?quartz - quartz)

    (restricted
      ?o        - limited
      ?category - category)

    (filled
      ?slot - slot)

    ;; ~ Axioms / Derived ~
    ;; Current elemental value of each line.

    (enough-power-for-element
      ?element - element
      ?line    - line
      ?art     - art)

    (line-active
      ?line - line
      ?art  - art)

    (orbament-active
      ?orbament - orbament
      ?art      - art)

    (any-active
      ?art - art)

    ;; ~ State machine ~ ;;

    (action-state)

    (quartz-to-be-modified
      ?quartz - quartz)
    (category-to-be-modified
      ?category - category)
    (slot-to-be-modified
      ?slot - slot)
    (orbament-to-be-modified
      ?orbament - orbament)

    ; Addition / Subtraction

    (addition-state)
    (subtraction-state)
    (unmark-state)

    (to-be-activated
      ?line - line)
    (modified
      ?element - element
      ?line - line)
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
                       (not (contains-quartz ?slot ?quartz))
                       (belongs ?quartz ?category)
                       ;; Check the amount in the inventory
                       (inventory-count ?quartz ?count)
                       (less-than n0 ?count)    ; ?count > 0
                       (addition n1 ?next-count ?count)
                       ;; If the quartz has an orbament-wide restriction, then
                       ;; check there is no other quartz with the same
                       ;; restriction in the same orbament.
                       (not (restricted ?orbament ?category)))
                       ;; Otherwise, check that there is no line that connects
                       ;; the slot which has a line-wide restriction.
                       ;; (imply (not (orbament-wide ?category))
                       ;;        (forall (?line - line)
                       ;;          (imply (connects ?line ?slot)
                       ;;                 (not (restricted ?line ?slot))))))
    :effect (and (filled ?slot)
                 (quartz-to-be-modified ?quartz)
                 (slot-to-be-modified ?slot)
                 (contains-quartz ?slot ?quartz)
                 (not (inventory-count ?quartz ?count))
                 (restricted ?orbament ?category)
                 (inventory-count ?quartz ?next-count)
                 (increase (total-cost) 1)
                 (not (action-state))
                 (addition-state)))

  ;;; Removal

  (:action remove
    :parameters (?quartz     - quartz
                 ?category   - category
                 ?slot       - slot
                 ?orbament   - orbament
                 ?count      - natural
                 ?next-count - natural)
    :precondition (and (action-state)
                       (contains-slot ?orbament ?slot)
                       (filled ?slot)
                       (contains-quartz ?slot ?quartz)
                       (belongs ?quartz ?category)
                       (restricted ?orbament ?category)
                       ;; Check the amount in the inventory
                       (inventory-count ?quartz ?count)
                       (addition n1 ?count ?next-count))
    :effect (and (not (filled ?slot))
                 (quartz-to-be-modified ?quartz)
                 (slot-to-be-modified ?slot)
                 (not (restricted ?orbament ?category))
                 (not (contains-quartz ?slot ?quartz))
                 (not (inventory-count ?quartz ?count))
                 (inventory-count ?quartz ?next-count)
                 (increase (total-cost) 1)
                 (not (action-state))
                 (subtraction-state)))

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

  ;;; Unmarking

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


  ;;; Subtraction

  (:action element-subtraction
    :parameters (?line    - line
                 ?slot    - slot
                 ?quartz  - quartz
                 ?element - element
                 ?old     - natural
                 ?power   - natural
                 ?new     - natural)
    :precondition (and (subtraction-state)
                       (slot-to-be-modified ?slot)
                       (quartz-to-be-modified ?quartz)
                       (connects ?line ?slot)
                       (not (modified ?element ?line))
                       (value ?element ?line ?old)
                       (power ?element ?quartz ?power)
                       (addition ?new ?power ?old))
    :effect (and (modified ?element ?line)
                 (not (value ?element ?line ?old))
                 (value ?element ?line ?new)))

  (:action finish-line-subtraction
    :parameters (?line - line
                 ?slot - slot)
    :precondition (and (subtraction-state)
                       (slot-to-be-modified ?slot)
                       (connects ?line ?slot)
                       (not (to-be-activated ?line))
                       (forall (?element - element)
                         (modified ?element ?line)))
    :effect (to-be-activated ?line))

  (:action finish-subtraction
    :parameters (?quartz - quartz
                 ?slot   - slot)
    :precondition (and (subtraction-state)
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
                 (not (subtraction-state))
                 (unmark-state)))

  ;;;                        ~ Derived  predicates ~                        ;;;

  (:derived
    (enough-power-for-element
      ?element - element
      ?line    - line
      ?art     - art)
    (exists (?v - natural)
      (exists (?r - natural)
        (and (value ?element ?line ?v)
             (requirement ?element ?art ?r)
             (not (less-than ?v ?r))))))

  (:derived
    (line-active
      ?line - line
      ?art  - art)
    (and (forall (?element - element)
           (enough-power-for-element ?element ?line ?art))))

  (:derived
    (orbament-active
      ?orbament - orbament
      ?art      - art)
    (and (exists (?line - line)
           (and (contains-line ?orbament ?line)
                (line-active ?line ?art)))))

  (:derived
    (any-active
      ?art - art)
    (and (exists (?line - line)
           (line-active ?line ?art))))


)

; vim: ft=scheme
