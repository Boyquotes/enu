# Parts of an Enu Program

Enu is programmed with a language called [Nim](https://nim-lang.org). This tutorial teach some of the 
basics of Nim, as well as a few special features that are unique to Enu.

## Comments

Comments are a way to leave notes to yourself or other programmers. They can be 
used for lots of different things, but generally provide more information on how 
something works or why it was done a certain way. They can also have more 
general information, such as the author of the code and when it was written. 
They start with a `#` sign. Everything else on the line is ignored.

```nim
# Copyright Scott Wadden, 2022

var last_row = false # we only want to change colors on the last row
```

## Types

Every piece of data in Enu has a type. These are the most common:

- `bool` - a `true` or `false` value. Example: `drawing = false`

- `Number` - a number with a decimal, like `1.0`. Numbers without decimals, like 
  `1` will usually auto convert, but if something isn't working, try adding a 
  decimal. Example: `var age = 12.5`

- `Text` - Any combination of letters, numbers and punctuation, contained inside 
  double quotes. Example: `var name = "Sackville Coding Club"`

- `Color` - Any one of `blue`, `red`, `green`, `black`, `white`, `brown` or 
  `eraser`. Someday more colors will be available. Example `color = green`

- `Position` - The place of something in the world. Example: 
  `me.position = player.position`

- `Thing` - Anything that exists in the Enu world. This could be something you 
  build, a robot, or the player.

<div style="page-break-after: always;"></div>

## Variables

A variable is used to store data. The value is usually set when it is created, 
and can be modified later. A variable must always hold the same type of data.

```nim
# ok:
var age = 12
if birthday:
  age = age + 1

if reset:
  age = 0

# not ok. Age must always be a number, not text:
var age = 12
if birthday:
  age = "13 years old"                          
```

Usually variables are defined with just a value, but sometimes you need to 
specify their type as well. This could be because you're not ready to give it a 
value, or because you want it to contain more than one kind of `Thing`.

For example:

```nim
# this won't work because `enemy` gets automatically set to the type of 
# `Player`, so other things won't work:
var enemy = player
enemy = me

# it will work if we do it like this, since `player` and `me` are both `Thing`
var enemy: Thing
enemy = player
enemy = me
```

<div style="page-break-after: always;"></div>

Usually each variable starts with `var`, but you can also indent to define 
multiple variables with a single `var`.

```nim
var name = "Scott"
var age = 43
var town = "Sackville"

# this is exactly the same as the above

var
  name = "Scott"
  age = 43
  town = "Sackville"
```

## Special Variables

Enu has some built in variables.

- `me` - the `Thing` that we're working on in the current script.

- `speed` - a `Number` to get or set our current speed. `1.0` by default.

- `color` - the current drawing `Color`. `blue` by default.

- `scale` - a `Number` to grow or shrink a `Thing`. `1.0` by default. Be careful 
  about making this too small. You might lose the `Thing` you're working on.

- `position` - where a `Thing` is. You can use this to move something 
  immediately. `position = player.position` would teleport `me` to the player.

- `drawing` - a `bool` that indicates if commands like `forward` or `back` should 
  draw blocks. `true` by default. `drawing = false` would let you move without 
  drawing anything, which could be useful for making a hole or a new object.

- `glow` - how bright a `Thing` is. Can be used to make something flash, or to 
  highlight it.

<div style="page-break-after: always;"></div>

## Blocks

Blocks start with a `:`, and are then indented by two spaces. Everything that's 
inside the block is controlled by whatever started it.

- `if` - an `if` block will only run if the statement is `true`.

```nim
var length = 0
...
if length == 0:
  glow = 1
  echo "You need to provide a length!"
  # both of the above only happen if `length` is 0.
```

- `times` - Make something happen more than once.

```nim
4.times:
  forward 5
  turn right
  # the above each happen 4 times (which draws a square!)

back 20
# this only happens once, since it isn't in a `times` block.

8.times(side):
  # It's also possible to see how many times we've already performed 
  # the action by passing `times` an index variable.
  # This starts from 0. in this example we're storing the counter in 
  # a variable called `side`. Because we're doing this 8 times, 
  # `side` will be set first to 0, then 1, 2, 3, 4, 5, 6, 7.
  forward 5
  if side != 4:
    turn right
  else:
    turn left

echo "We drew a bow tie!"
echo "This will only be printed once because it isn't in a times block"
```
  
