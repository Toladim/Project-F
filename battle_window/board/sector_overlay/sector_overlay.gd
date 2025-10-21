extends Control


const TILE_SIZE := Vector2i(32, 32)
const TILE_OFFSET := Vector2i(1, 1.35)

var sectors:Array[SectorData]

func _draw():
	var full_tile = TILE_SIZE + TILE_OFFSET
	var draw_offset = Vector2i(0, 5)
	
	for sector in sectors:
		var screen_points := PackedVector2Array()
		for point in sector.points:
			screen_points.append(point * full_tile + draw_offset)

		for i in range(screen_points.size()):
			var a = screen_points[i]
			var b = screen_points[(i + 1) % screen_points.size()]
			draw_line(a, b, Color(0, 0, 0, 0.6), 3.5)
