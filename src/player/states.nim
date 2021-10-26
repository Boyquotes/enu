import godotapi / node
import std / tables
import model_citizen
import engine / engine

type
  TargetFlag* = enum
    Reticle, Targeting, MouseCaptured, CommandMode, Editing

  GameState* = object
    target_flags*: TrackedSet[TargetFlag]
    requested_target_flags: set[TargetFlag]
    open_file*: string
    open_engine*: Engine
    nodes*: tuple[
      game: Node,
      player: Node
    ]

proc set_flag(flags: var set[TargetFlag], flag: TargetFlag, add: bool) =
  if add:
    flags.incl(flag)
  else:
    flags.excl(flag)

proc apply_target_flags(state: var GameState) =
  let requested = state.requested_target_flags
  var flags: set[TargetFlag]
  flags.set_flag(CommandMode, CommandMode in requested)
  flags.set_flag(Targeting, Targeting in requested)
  flags.set_flag(Editing, Editing in requested)

  if MouseCaptured in requested:
    flags.incl(MouseCaptured)
  if Editing in requested:
    flags.excl(MouseCaptured)
  if CommandMode in requested:
    flags.incl(MouseCaptured)
  if Reticle in requested and MouseCaptured in flags:
    flags.incl(Reticle)

  state.target_flags.set = flags

proc `mouse_captured=`*(state: var GameState, captured: bool) =
  state.requested_target_flags.set_flag(MouseCaptured, captured)
  state.apply_target_flags()

proc `command_mode=`*(state: var GameState, command_mode: bool) =
  state.requested_target_flags.set_flag(CommandMode, command_mode)
  state.apply_target_flags()

proc `targeting=`*(state: var GameState, targeting: bool) =
  if targeting:
    state.requested_target_flags.incl(Targeting)
    state.requested_target_flags.excl(Reticle)
  else:
    state.requested_target_flags.excl(Targeting)
  state.apply_target_flags()

proc `reticle=`*(state: var GameState, reticle: bool) =
  if reticle:
    state.requested_target_flags.incl(Reticle)
    state.requested_target_flags.excl(Targeting)
  else:
    state.requested_target_flags.excl(Reticle)
  state.apply_target_flags()

proc `editing=`*(state: var GameState, editing: bool) =
  state.requested_target_flags.set_flag(Editing, editing)
  state.apply_target_flags()

proc mouse_captured*(state: GameState): bool = MouseCaptured in state.target_flags
proc command_mode*(state: GameState): bool = CommandMode in state.target_flags
proc targeting*(state: GameState): bool = Targeting in state.target_flags
proc reticle*(state: GameState): bool = Reticle in state.target_flags
proc editing*(state: GameState): bool = Editing in state.target_flags

when is_main_module:
  import std / [unittest, sugar]

  var state = GameState()

  state.reticle = true
  check:
    not state.reticle
    not state.targeting
    not state.command_mode
    not state.mouse_captured

  state.mouse_captured = true
  check:
    state.reticle
    state.mouse_captured
    not state.targeting

  state.targeting = true
  check:
    state.mouse_captured
    state.targeting
    not state.reticle

  state.mouse_captured = false
  state.reticle = true
  check:
    not state.reticle
    not state.mouse_captured
    not state.targeting
    not state.command_mode

  var added: set[TargetFlag]
  var removed: set[TargetFlag]

  state.target_flags.track proc(added_flags, removed_flags: set[TargetFlag]) =
    added = added_flags
    removed = removed_flags

  state.command_mode = true
  check:
    added == {CommandMode, MouseCaptured, Reticle}
    removed == {}
    state.command_mode
    state.mouse_captured
    state.reticle
    not state.targeting

  state.command_mode = false
  check:
    added == {}
    removed == {CommandMode, MouseCaptured, Reticle}

  state.mouse_captured = true
  check state.mouse_captured

  state.editing = true
  check not state.mouse_captured

  state.command_mode = true
  check state.mouse_captured

  state.mouse_captured = false
  check state.mouse_captured

  state.editing = false
  check state.mouse_captured

  state.command_mode = false
  check not state.mouse_captured
