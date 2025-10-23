extends Control
class_name FogLayer

var tile_size: Vector2
var grid_size: Vector2i
var fog_tiles: Array[FogTile] = []
var draw_offset = Vector2i(0, 5)

func _ready():
	_create_fog_tiles()

func _create_fog_tiles():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var fog_tile := FogTile.new()
			fog_tile.position = Vector2(x, y) * tile_size + Vector2(draw_offset)
			fog_tile.size = tile_size
			add_child(fog_tile)
			fog_tiles.append(fog_tile)

func setup(p_grid_size: Vector2i, p_tile_size: Vector2) -> void:
	grid_size = p_grid_size
	tile_size = p_tile_size
	_create_fog_tiles()

func update_fog(visibility_map: Callable):
	for tile in fog_tiles:
		var grid_pos = (tile.position / tile_size).floor()
		var visible = visibility_map.call(Vector2i(grid_pos.x, grid_pos.y))
		tile.set_fog_visible(visible)
