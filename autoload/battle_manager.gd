@tool
extends Node
class_name BattleManager

var units:= []
#var round:int= 0
var active_unit_index:int= 0
var sectors:Array[SectorData] = []

func _ready():
	load_sectors_from_json("res://data/board/sectors.json")


func load_sectors_from_json(path: String):
	sectors.clear()

	var json_text = FileAccess.open(path, FileAccess.READ).get_as_text()
	var raw_sectors = JSON.parse_string(json_text)

	for raw in raw_sectors:
		var sector := SectorData.new()
		sector.name = raw["name"]
		sector.height = raw["height"]
		
		sector.points = []
		for p in raw["points"]:
			sector.points.append(Vector2i(p[0], p[1]))
		
		sector.tiles = []
		for t in raw["tiles"]:
			sector.tiles.append(Vector2i(t[0], t[1]))
		
		sectors.append(sector)
		
func get_sector_at_tile(tile_pos: Vector2i) -> SectorData:
	for sector in sectors:
		if sector.contains_tile(tile_pos):
			return sector
	return null

func get_height_at_tile(tile_pos: Vector2i) -> float:
	var sector = get_sector_at_tile(tile_pos)
	if sector:
		return float(sector.height)
	return 0.0
