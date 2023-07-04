import types, vm_bridge_utils

proc link_dependency_impl*(dep: Unit) =
  raise_assert "link_dependency_impl must be implemented by host"

bindings:
  proc action_running*(self: Unit): bool
  proc `action_running=`*(self: Unit, value: bool)
  proc yield_script*(self: Unit)
  proc begin_move*(self: Unit, direction: Vector3, steps: float, move_mode: int)
  proc begin_turn*(
      self: Unit, axis: Vector3, steps: float, lean: bool, move_mode: int)

  proc sleep_impl*(seconds = 1.0)
  proc position_set*(self: Unit, position: Vector3)

proc new_markdown_sign_impl*(
  self: Unit, instance: Sign, markdown: string, title = "", width = 1.0,
  height = 1.0, size = 32, zoomable = true, billboard = false) = discard
