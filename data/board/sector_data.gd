class_name SectorData
extends RefCounted

var name: String
var height: int
var points: Array[Vector2i]

func contains_tile(tile_pos: Vector2i) -> bool:
	var polygon := PackedVector2Array()
	for point in points:
		polygon.append(point)

	return Geometry2D.is_point_in_polygon(tile_pos, polygon)
