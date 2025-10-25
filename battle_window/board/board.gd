extends Control
class_name Board

@onready var sector_overlay: Control = %sector_overlay
@onready var fog_layer: FogLayer = %fog_layer

const TILE_SIZE:= Vector2(32, 32)
const TILE_OFFSET:= TILE_SIZE + Vector2(1, 1)
const GRID_SIZE:= Vector2(34,24)

var tiles:= []
var are_sectors_visible:= true

func _ready():
	BattleManager.load_sectors_from_json("res://data/board/sectors.json")
	sector_overlay.sectors = BattleManager.sectors
	sector_overlay.queue_redraw()
	_create_tiles()
	fog_layer.setup(GRID_SIZE, TILE_OFFSET)

func _create_tiles():
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var tile = Tile.new()
			tile.position_in_grid = Vector2i(x, y)
			tile.position = _grid_to_screen_position(x, y)
			tile.set_size(TILE_OFFSET)
			add_child(tile)
			tiles.append(tile)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()
		var x = floor(mouse_pos.x / TILE_OFFSET.x)
		var y = floor(mouse_pos.y / TILE_OFFSET.y)

		var tile_pos = Vector2i(x, y)
		
		if x >= 0 and x < GRID_SIZE.x and y >= 0 and y < GRID_SIZE.y:
			print("Kliknięto tile:", tile_pos)
		var sector = BattleManager.get_sector_at_tile(tile_pos)
		if sector:
			print(" → Sektor:", sector.name, " | Wysokość:", sector.height)
		else:
			print(" → Tile nie należy do żadnego sektora")
	
	if event is InputEventMouse:
		var mouse_pos = get_local_mouse_position()
		var tile_x = floor(mouse_pos.x / TILE_OFFSET.x)
		var tile_y = floor(mouse_pos.y / TILE_OFFSET.y)
		var tile_pos = Vector2i(tile_x, tile_y)

		if tile_pos.x >= 0 and tile_pos.x < GRID_SIZE.x and tile_pos.y >= 0 and tile_pos.y < GRID_SIZE.y:
			update_fov_with_heights(tile_pos)


func _grid_to_screen_position(x: int, y: int) -> Vector2: return Vector2(x, y) * TILE_OFFSET

func toggle_sectors():
	sector_overlay.visible = are_sectors_visible

func update_fov_with_heights(origin: Vector2i, max_distance := 50):
	var fov = SimpleFOV.new(GRID_SIZE)

	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var pos = Vector2i(x, y)
			var h = BattleManager.get_height_at_tile(pos)
			fov.set_height(pos, h)

	fov.compute(origin, max_distance)

	fog_layer.update_fog(func(pos): return fov.is_in_view(pos))
