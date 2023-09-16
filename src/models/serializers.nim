import std / [json, jsonutils, sugar, tables, strutils, os]
import core, models
import controllers / script_controllers / scripting

var load_chunks {.threadvar.}: bool

type WorldInfo = object
  enu_version, format_version: string

proc to_json_hook(self: Color): JsonNode =
  result = if self == action_colors[eraser]:
    %""
  else:
    for i, color in Colors.enum_fields:
      if self == action_colors[Colors(i)]:
        return %color
    %self.to_html_hex

proc from_json_hook(self: var Color, json: JsonNode) =
  let hex = json.get_str
  if hex == "":
    self = action_colors[eraser]
  else:
    for i, color in Colors.enum_fields:
      if color == hex:
        self = action_colors[Colors(i)]
        return
    self = hex.parse_html_hex

proc to_json_hook(self: VoxelInfo): JsonNode  =
  %* [self.kind.ord, jsonutils.to_json(self.color)]

proc from_json_hook(self: var VoxelInfo, json: JsonNode) =
  self.kind = VoxelKind(json[0].get_int)
  self.color = json[1].json_to(Color)

proc to_json_hook(self: Vector3): JsonNode =
  %[self.x, self.y, self.z]

proc from_json_hook(self: var Vector3, json: JsonNode) =
  self.x = json[0].get_float
  self.y = json[1].get_float
  self.z = json[2].get_float

proc to_json_hook(shared_edits: ZenTable[string, Table[Vector3, VoxelInfo]]):
    JsonNode =

  let edits = collect:
    for id, edits in shared_edits:
      if edits.len > 0:
        let edit = collect:
          for loc, info in edits:
            (loc, info)
        {id: edit}

  result = jsonutils.to_json(edits)

proc from_json_hook(self: var Table[Vector3, VoxelInfo],
    json: JsonNode) {.gcsafe.} =

  ensure load_chunks
  for chunks in json:
    for chunk in chunks[1]:
      let location = chunk[0].json_to(Vector3)
      let info = chunk[1].json_to(VoxelInfo)
      self[location] = info

proc from_json_hook(self: var ZenTable[string, Table[Vector3, VoxelInfo]],
    json: JsonNode) =

  ensure not load_chunks
  for id, edits in json:
    for edit in edits:
      if id notin self:
        self[id] = init_table[Vector3, VoxelInfo]()
      let location = edit[0].json_to(Vector3)
      let info = edit[1].json_to(VoxelInfo)
      var locations = self[id]
      locations[location] = info
      self[id] = locations

proc to_json_hook(self: Build): JsonNode =
  %* {
    "id": self.id,
    "start_transform": jsonutils.to_json(self.start_transform),
    "start_color": jsonutils.to_json(self.start_color),
    "edits": jsonutils.to_json(self.shared.edits)
  }

proc from_json_hook(self: var Build, json: JsonNode) =
  let color = json["start_color"].json_to(Color)
  self = Build.init(id = json["id"].json_to(string), transform =
      json["start_transform"].json_to(Transform), color = color)

  if load_chunks:
    var edit = init_table[Vector3, VoxelInfo]()
    edit.from_json(json["chunks"])
    self.shared.edits[self.id] = edit
  else:
    self.shared.edits.from_json(json["edits"])

proc to_json_hook(self: Bot): JsonNode {.gcsafe.} =
  %* {
    "id": self.id,
    "start_transform": jsonutils.to_json(self.start_transform),
    "start_color": jsonutils.to_json(self.start_color),
    "edits": jsonutils.to_json(self.shared.edits)
  }

proc from_json_hook(self: var Bot, json: JsonNode) =
  self = Bot.init(id = json["id"].json_to(string), transform =
      json["start_transform"].json_to(Transform))

  if not load_chunks:
    self.shared.edits.from_json(json["edits"])

proc save*(unit: Unit) =
  if not ?unit.clone_of:
    let data =
      if unit of Build:
        jsonutils.to_json(Build(unit)).pretty
      elif unit of Bot:
        jsonutils.to_json(Bot(unit)).pretty
      else:
        return
    create_dir unit.data_dir
    write_file unit.data_file, data

    for unit in unit.units:
      unit.save

proc save_world*(world_dir: string) =
  if Server in state.local_flags:
    debug "saving world"
    let world = WorldInfo(enu_version: enu_version, format_version: "v0.9.1")
    write_file world_dir / "world.json",
        jsonutils.to_json(world).pretty

    for unit in state.units:
      if Dirty in unit.global_flags:
        unit.save
        unit.global_flags -= Dirty

  else:
    debug "not server. Skipping save."

proc load_units(parent: Unit) =
  let opts = JOptions(allow_missing_keys: true)
  let path =
    if ?parent:
      parent.data_dir
    else:
      state.config.data_dir
  for dir in walk_dirs(path / "*"):
    let unit_id = dir.split_path.tail
    let data_file = read_file(dir / unit_id & ".json").parse_json
    var unit: Unit
    if unit_id.starts_with("bot_"):
      unit = data_file.json_to(Bot, opts)
    elif unit_id.starts_with("build_"):
      unit = data_file.json_to(Build, opts)
    else:
      quit "Unknown unit type: " & unit_id

    unit.global_flags += ScriptInitializing
    if parent.is_nil:
      state.units.add(unit)
    else:
      parent.units.add(unit)
    if unit of Build:
      Build(unit).reset_bounds
      Build(unit).restore_edits

    if file_exists(unit.script_ctx.script):
      unit.code = Code.init(read_file(unit.script_ctx.script))
    else:
      unit.global_flags -= ScriptInitializing

proc unload_world*(worker: Worker) =
  state.global_flags += LoadingWorld
  state.push_flag LoadingScript
  state.pop_flag Playing
  state.units.clear_all
  state.pop_flag LoadingScript
  state.global_flags -= LoadingWorld

proc load_world*(worker: Worker, world_dir: string) =
  state.global_flags += LoadingWorld
  state.push_flag LoadingScript
  var config = state.config

  config.world_dir = world_dir
  config.data_dir = join_path(config.world_dir, "data")
  config.script_dir = join_path(config.world_dir, "scripts")

  if not file_exists(config.world_dir / "world.json"):
    for file in walk_dir(config.lib_dir / "projects"):
      if config.world.ends_with file.path.split_file.name:
        file.path.copy_dir(config.world_dir)

  create_dir(config.data_dir)
  create_dir(config.script_dir)

  state.config = config

  let world_file = world_dir / "world.json"
  debug "loading ", world_file
  if file_exists(world_file):
    let world_json = read_file(world_file)
    let world = world_json.parse_json.json_to(WorldInfo)
    load_chunks = world.format_version == "v0.9"

  dont_join = true
  worker.retry_failures = true
  load_units(nil)
  worker.retry_failed_scripts()
  worker.retry_failures = false
  dont_join = false
  for unit in state.units:
    unit.global_flags -= Dirty
  state.pop_flag LoadingScript
  state.global_flags -= LoadingWorld
