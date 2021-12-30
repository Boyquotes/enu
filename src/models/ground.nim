import std / [sugar]
import pkg / [model_citizen, print]
import types, builds, bots, core

proc surrounding(point: Vector3): seq[Vector3] =
  collect(new_seq):
    for x in 0..2:
      for y in 0..2:
        for z in 0..2:
          point + vec3(x - 1, y - 1, z - 1)

proc fire[T](self: Ground[T], state: GameState[T]) =
  let point = (self.target_point - vec3(0.5, 0, 0.5)).trunc
  if state.tool == Block:
    self.painting = true
    let points = point.surrounding
    let neighbour = state.units.find_first(points)
    if neighbour:
      let local = point.local_to(neighbour)
      neighbour.draw(local, (Manual, state.selected_color))
    else:
      state.units += Build.init(T, state, position = point, root = true, color = state.selected_color)
  elif state.tool == Place:
    var t = Transform.init(origin = point)
    state.units += Bot.init(T, transform = t)

proc init*(_: type Ground, T: type, node: T, state: GameState[T]): Ground[T] =
  let self = Ground[T](flags: ZenSet[ModelFlags].init, node: node)

  state.input_flags.track proc(changes: auto) =
    for change in changes:
      if Added in change.changes and Hover in self.flags:
        if change.obj == Primary:
          self.fire(state)
      if Removed in change.changes and change.obj in {Primary, Secondary}:
        self.painting = false

  self.flags.track proc(changes: auto) =
    if self.painting:
      for change in changes:
        if Added in change.changes and change.obj == TargetMoved:
          self.fire(state)

  result = self
