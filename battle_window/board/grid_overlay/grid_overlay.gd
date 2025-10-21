extends Control

@onready var grid_button: Button = %grid_button

@export var tile_size := Vector2(33, 33)
@export var cols := 34
@export var rows := 24
@export var grid_color := Color(0.0, 0.0, 0.0, 0.2)
@export var grid_thickness := 2.0
var is_grid_on:bool = true


func _ready():
	size = tile_size * Vector2(cols, rows)
	position = (get_viewport_rect().size - size) / 2 
	grid_button.connect("pressed", _on_grid_button_pressed)

func _draw():
	for x in range(cols + 1):
		var x_pos = x * tile_size.x
		draw_line(Vector2(x_pos, 0), Vector2(x_pos, size.y), grid_color, grid_thickness)
	for y in range(rows + 1):
		var y_pos = y * tile_size.y
		draw_line(Vector2(0, y_pos), Vector2(size.x, y_pos), grid_color, grid_thickness)

func _process(_delta):
	queue_redraw()

func _on_grid_button_pressed():
	is_grid_on =! is_grid_on
	toggle_grid()

func toggle_grid():
	if is_grid_on:
		self.show()
	else:
		self.hide()
