extends Node

var units:= []
#var round:int= 0
var active_unit_index:int= 0
var sectors:Array[SectorData] = []

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
		sectors.append(sector)
		
func get_sector_at_tile(tile_pos: Vector2i) -> SectorData:
	for sector in sectors:
		if tile_pos in sector.points:
			return sector
	return null
