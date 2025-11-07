@tool
extends Control
class_name FogLayer

@export var grid_size: Vector2i = Vector2i(34, 24)
@export var tile_size: Vector2 = Vector2(33, 33)
@export var fov: SimpleFOV
@export var origin: Vector2i = Vector2i(16, 16)
@export var battle_manager: BattleManager
@export var debug_enabled: bool = true

var fog_tiles: Array[FogTile] = []
var draw_offset := Vector2(0, 5)

func _ready():
	if Engine.is_editor_hint():
		_create_fog_tiles()
		_refresh_fog()

	if fov:
		fov.set_meta("fog_layer", self)

func _process(_delta):
	if Engine.is_editor_hint():
		_refresh_fog()
	else:
		queue_redraw()

func _refresh_fog():
	if not fov:
		push_warning("⚠️ Brak przypisanego FOV w FogLayer!")
		return

	fov.size = grid_size
	fov.clear()

	if battle_manager:
		for y in range(grid_size.y):
			for x in range(grid_size.x):
				var pos = Vector2i(x, y)
				var h = battle_manager.get_height_at_tile(pos)
				fov.set_height(pos, h)

	fov.compute(origin, 50)
	_update_fog_tiles()

func _create_fog_tiles():
	_clear_fog_tiles()
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var fog_tile := FogTile.new()
			fog_tile.position = Vector2(x, y) * tile_size + draw_offset
			fog_tile.size = tile_size
			add_child(fog_tile)
			fog_tiles.append(fog_tile)

func _clear_fog_tiles():
	for t in fog_tiles:
		t.queue_free()
	fog_tiles.clear()

func _update_fog_tiles():
	for tile in fog_tiles:
		var grid_pos = ((tile.position - draw_offset) / tile_size).floor()
		var visible = fov.is_in_view(Vector2i(grid_pos.x, grid_pos.y))
		tile.set_fog_visible(visible)

func _draw():
	if not debug_enabled or not fov or fov.debug_rays.is_empty():
		return

	for ray in fov.debug_rays:
		if ray.size() != 2:
			continue

		var from_tile: Vector2i = ray[0]
		var to_tile: Vector2i = ray[1]

		var from_px = Vector2(from_tile) * tile_size + tile_size * 0.5 + draw_offset
		var to_px = Vector2(to_tile) * tile_size + tile_size * 0.5 + draw_offset

		draw_line(from_px, to_px, Color(1, 0, 0, 0.25), 1.0)
