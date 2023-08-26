import nimib, nimibook
import enuib

nb_init(theme = use_enu)
nb_text: """

# Commands

## `move/build`

When dealing with a `Build` unit, commands can do different things depending on whether the unit is in `build`
mode or `move` mode. `move` mode moves the unit around, while `build` creates new blocks. By default a `Build` is in
`build` mode. Often you'll pass the `me` unit to `move/build`, but it's also possible to pass other units. For example:

```nim
build me # generally not required, as it's the default

# make a shape:
back 5
right 3

# move it into position:
move me
up 3

# create another unit and add some blocks
var enemy = ghost.new
build enemy
down 5

# move it into position
move enemy
up 5
```

It's also possible to call commands directly against a unit instance, but they will always use `move` mode, regardless
of which mode is in use:

```nim
build enemy
up 5 # build 5 blocks up
enemy.up 5 # move up 5
```

## `forward/back/up/down/left/right`

Move or build x number of blocks in the specified direction. Defaults to 1 block.

```nim
forward 5
enemy.up 2
```

## `turn`

Turn a unit. Can be passed:
- a number in degrees. Positive for clockwise, negative for counter-clockwise. Ex. `turn 180`
- a direction (`forward/back/up/down/left/right`) which will turn in that direction. 90 degrees by default.
  Ex. `turn left`, or `turn up, 180`
- a unit to turn towards. Ex. `turn player`
- a negative unit to turn away from. Ex. `turn -player`

## `near(less_than = 5.0) / far(greater_than = 100.0)`

Returns true or false if a unit is nearer/farther than the specified distance. For example:

```nim
if player.near:
  echo "the player is 5m or closer"

if player.far:
  echo "the player is 100m or farther"

if player.near(10):
  echo "the player is 10m or closer"

if player.far(25):
  echo "the player is 25m or farther"
```

## `hit`

If a unit is touching another unit, return the vector of the contact. Defaults to testing against `me`. For example:

```nim
if player.hit:
  echo "I'm touching the player"

if player.hit == UP:
  echo "The player is on top of me"

if player.hit(enemy1):
  echo "The player hit enemy1"
```

## `position/postion=`

Gets or set the position of a unit as a Vector3. `me` by default.

```nim
if player.hit(enemy):
  # if the player hits `enemy`, reset the player position to the center of the world.
  player.position = vec3(0, 0, 0)
```

## `start_position`

The starting position of a unit. Missing currently, but will be in in 0.2.

## `speed/speed=`

Gets or sets the speed of a unit. `me` by default.

While building, speed refers to the number of blocks placed per frame. In the future this will be normalized to 60fps,
but currently the speed is tied to the framerate. Setting speed to 0 will build everything at once.

While moving, this is the movement speed in meters per second.

Switching between build and move mode doesn't impact the speed, except in the case of switching to move mode from build
mode with a speed of 0. `speed = 0` is extremely common for build mode, but makes things appear broken in move mode,
as nothing will actually move, so switching to move mode with a speed of 0 will automatically reset the speed to 1.

## `scale/scale=`

Sets the scale/size of a unit. `me` by default.

## `glow/glow=`

Specifies the glow/brightness of a unit. `me` by default. Currently does nothing for bots, but will in the future.

## `global/global=`

Specifies if a unit is in global space, or the space of its parent. If `global = true` and the parent unit moves,
child units are unaffected. If `global = false`, the child will move with its parent. Does nothing for top level units,
as they're always global.

By default, new `Build` units are `global = false` and new `Bot` units are `global = true`.

## `rotation`

Gets the rotation of a unit as a Vector3.

## `velocity/velocity=`

Gets or sets the velocity of a unit, as a Vector3. Currently buggy.

## `color/color=`

Gets or sets a units color. `me` by default. For `Build` units, this only impacts blocks placed after the property
is set. For `Bot` units this does nothing, but in the future it will change their color.

## `bounce`

Bounces a unit in the air. Currently only works for the player.

## `save/restore`

`Build` units only. `save` the position, direction, drawing state, and color of the draw point, to `restore` it later.
Can optionally take a name string to enable saving/restoring multiple points.

## `reset`

Instantly return unit to start position and resets rotation and scale.

## `home`

Moves a unit to its start position via a `forward`, `left`, `down` sequence with appropriate values. Can fail if there
are obstructions along the way. Compare `position` to `start_position` after running to test for success.

## `sleep(seconds = -1.0)`

Do nothing for the specified number of seconds. If no argument is provided, or the argument is < 0, this will wait for
0.5 seconds or until unit is interrupted, which will end the `sleep` prematurely. This allows the following:

```nim
forever:
  sleep()
  if player.hit:
    echo "ouch!"
```

Currently, any collision will trigger an interrupt. This will be expanded in the future.

## `forever`

Alias for `while true`

## `cycle`

Alternate between a list of values, returning the next element each time the cycle is called.

```nim
forever:
  sleep 1
  echo cycle("one", "two", "three")
```

"""
nb_save
