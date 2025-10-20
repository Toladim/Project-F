extends Control

var tile_size:= Vector2(32, 32)
var grid_size:= Vector2(35,25)
var tiles:= []

func _ready():
	_create_tiles()
	

func _create_tiles():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var tile = Tile.new()
			tile.position_in_grid = Vector2i(x, y)
			tile.position = _grid_to_screen_position(x, y)
			tile.set_size(tile_size)
			add_child(tile)
			tiles.append(tile)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()
		var x = int(mouse_pos.x / (tile_size.x))
		var y = int(mouse_pos.y / (tile_size.y))

		if x >= 0 and x < grid_size.x and y >= 0 and y < grid_size.y:
			print("Kliknięto tile:", Vector2i(x, y))



func _grid_to_screen_position(x: int, y: int) -> Vector2: return position + Vector2(x, y) * tile_size
