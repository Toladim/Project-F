class_name SectorData
extends RefCounted

var name: String
var height: int
var points: Array[Vector2i]
var tiles: Array[Vector2i]

func contains_tile(tile_pos: Vector2i) -> bool:
	return tile_pos in tiles
