extends Control


const TILE_SIZE := Vector2(32, 32)
const TILE_OFFSET := Vector2(1, 1.25)

var sectors: Array = []

var are_sectors_visible:= false



func _draw():
	var full_tile = TILE_SIZE + TILE_OFFSET

	for sector in sectors:
		var screen_points := PackedVector2Array()

		for point in sector.points:
			screen_points.append(point * full_tile)

		for i in range(screen_points.size()):
			var a = screen_points[i]
			var b = screen_points[(i + 1) % screen_points.size()]
			draw_line(a, b, Color(0, 0, 0, 0.6), 2.5)
			
func _on_sector_button_pressed():
	are_sectors_visible != are_sectors_visible
	
