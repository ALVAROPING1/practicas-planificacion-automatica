# Problem file description

This directory describes the different problems in a simplified manner. When
creating the problem file, special care must be taken when adding the
predicates. They are JSON objects with the following fields:

## `name`
Required. The name of the problem.

## `description`
Required. A brief description of what it attempts to do.

## `characters`
Optional. A list of characters that are enabled for the test. If a character is
not in the list, it is disabled. By default all characters are enabled.

## `elements`
Optional. The elements that are enabled for the domain. There are 7 elements,
removing one element also removes all arts that require it and quartz that
provide it.  The removal of these arts and quartz may be strict or not. See
`strict`.

## `strict`
Optional. Value is either `true` or `false`. When at least one element is
disabled we can choose between two strategies:

 1. When `true`. Remove all arts and quartz that name it. For example if we
    disable only the space element then arts such as «Rayo» (that requires 3
    wind, 2 space) would be disabled. Similarly all space quartz or quartz that
    provide "Space" element would also be disabled such as «PE 1» (provides 1
    mirage 1 space).
 2. When `false`. Then the only moment a quartz or an art are removed is if
    they only provide or require the disabled elements. So «PE 1» would not be
    removed because it still provides 1 of mirage. But «Precisión 1» would be
    removed because it only provides space.

Also characters whose orbament have elemental restriction for a disabled
element are set to allow any quartz of any element.

## `init`
Optional (but there is no meaning on not providing it). It sets up the initial
condition. It contains the following fields:

### `configuration`
Optional. It provides the initial orbament configuration for each of the
characters. It is a dictionary where the key is the name of the character. The
values are dictionaries with key is the slot (1-based integer) and the value is
the quartz that is set in that position.

### `inventory`
Optional. A dictionary with quartz as a key and a natural number as a value. It
tells what quartz there are in the inventory. Quartz set to characters are not
subtracted from inventory. So if one character has «Ataque 1», there is no need
to put one «Ataque 1» in inventory. Likewise if there is a character with
«Ataque 1» and one «Ataque 1» in inventory, that number isn't decreased.

The other value that it can take is an integer. It sets all elements to that
integer value.

## `goal`
Optional. A list of dictionaries with different goals. Everything is _and_ed
together. The objects have:

### `arts`
Required. A list of arts that must be activated.

### `orbament`
Optional. The name of the character.

 - If specified, then it means that the specified line (if not specified, then
   **any** line) from that character activates the given art list.
 - If not specified, it means that any character can have any art.

### `line`
Optional. If specified the line where the arts must be activated in that
character.
