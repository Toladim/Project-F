extends Control

@onready var sector_button: Button = %sector_button
@onready var sector_overlay: Control = %sector_overlay

const  TILE_SIZE:= Vector2(32, 32)
const TILE_OFFSET:= TILE_SIZE + Vector2(1, 1.25)
const GRID_SIZE:= Vector2(35,25)

var tiles:= []
var sectors:= []
var are_sectors_visible:= false

func _ready():
	var file = FileAccess.open("res://data/sectors.json", FileAccess.READ)
	sectors = JSON.parse_string(file.get_as_text())
	queue_redraw()
	_create_tiles()
	sector_button.connect("pressed", _on_sector_button_pressed)

func _create_tiles():
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var tile = Tile.new()
			tile.position_in_grid = Vector2i(x, y)
			tile.position = _grid_to_screen_position(x, y)
			tile.set_size(TILE_SIZE)
			add_child(tile)
			tiles.append(tile)

func _draw() -> void:
	for sector in sectors:
		var raw_points = sector["points"]
		var screen_points := PackedVector2Array()
		
		for p in raw_points:
			var pixel_pos = Vector2(p[0], p[1]) * TILE_OFFSET
			screen_points.append(pixel_pos)
		
		for i in range(screen_points.size()):
			var a = screen_points[i]
			var b = screen_points[(i + 1) % screen_points.size()]
			draw_line(a, b, Color(0.0, 0.0, 0.0, 0.608), 3.5)
			
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()
		var x = int(mouse_pos.x / (TILE_SIZE.x))
		var y = int(mouse_pos.y / (TILE_SIZE.y))
		if x >= 0 and x < GRID_SIZE.x and y >= 0 and y < GRID_SIZE.y:
			print("Kliknięto tile:", Vector2i(x, y))

func _grid_to_screen_position(x: int, y: int) -> Vector2: return Vector2(x, y) * TILE_SIZE

func _on_sector_button_pressed():
	are_sectors_visible != are_sectors_visible
	toggle_sectors()

func toggle_sectors():
	if are_sectors_visible:
		self.show()
	else:
		self.hide()
