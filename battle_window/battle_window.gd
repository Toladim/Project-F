extends Control
@onready var board: Control = %board
@onready var sector_button := %sector_button

func _ready():
	sector_button.connect("pressed", _on_sector_button_pressed)

func _on_sector_button_pressed():
	board.are_sectors_visible =! board.are_sectors_visible
	board.toggle_sectors()
