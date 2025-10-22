class_name SectorData
extends RefCounted

var name: String
var height: int
var points: Array[Vector2i]
var tiles: Array[Vector2i]

#const TILE_SIZE := Vector2(32, 32)
#const TILE_OFFSET := Vector2(1, 5)
#const DRAW_OFFSET := Vector2(0, 0)

func contains_tile(tile_pos: Vector2i) -> bool:
	return tile_pos in tiles
