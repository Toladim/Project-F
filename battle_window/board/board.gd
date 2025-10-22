extends Control
class_name Board

@onready var sector_overlay: Control = %sector_overlay

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

func _create_tiles():
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var tile = Tile.new()
			tile.position_in_grid = Vector2i(x, y)
			tile.position = _grid_to_screen_position(x, y)
			tile.set_size(TILE_OFFSET)
			add_child(tile)
			tiles.append(tile)
			
			#var debug_rect := ColorRect.new()
			#debug_rect.color = Color(1.0, 0.0, 0.0, 0.843)  # półprzezroczysty czerwony
			#debug_rect.position = tile.position
			#debug_rect.size = TILE_SIZE
			#add_child(debug_rect)


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
		

func _grid_to_screen_position(x: int, y: int) -> Vector2: return Vector2(x, y) * TILE_OFFSET

func toggle_sectors():
	sector_overlay.visible = are_sectors_visible
