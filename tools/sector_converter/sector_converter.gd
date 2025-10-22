extends Node
class_name SectorConverter

const INPUT_PATH := "res://data/board/sectors.json"
const OUTPUT_PATH := "res://tools/output/sectors_output.json"

## Rozmiar tile'a, potrzebny do rasteryzacji
const TILE_SIZE := Vector2(33, 33)
const TILE_OFFSET := Vector2(32, 0)
const FULL_TILE_SIZE := TILE_SIZE + TILE_OFFSET

func _ready():
	var raw_sectors = load_raw_sectors(INPUT_PATH)
	var sectors_with_tiles = []

	for sector in raw_sectors:
		var tiles := _rasterize_sector(sector["points"])
		var enriched := {
			"name": sector["name"],
			"height": sector["height"],
			"points": sector["points"],
			"tiles": tiles
		}
		sectors_with_tiles.append(enriched)

	export_sectors_json_clean(sectors_with_tiles, OUTPUT_PATH)
	print("Zapisano do:", OUTPUT_PATH)

func load_raw_sectors(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	return JSON.parse_string(text)

func _rasterize_sector(points: Array) -> Array:
	var polygon := PackedVector2Array()
	for p in points:
		polygon.append(Vector2(p[0], p[1]))

	var tiles := []

	var min_x = 999
	var min_y = 999
	var max_x = -999
	var max_y = -999
	for p in polygon:
		min_x = min(min_x, int(p.x))
		max_x = max(max_x, int(p.x))
		min_y = min(min_y, int(p.y))
		max_y = max(max_y, int(p.y))

	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var center = Vector2(x + 0.5, y + 0.5)
			if Geometry2D.is_point_in_polygon(center, polygon):
				tiles.append([x, y])

	return tiles




# --- Formatowany eksport JSON z czytelnym points/tiles ---
func export_sectors_json_clean(output_sectors: Array, file_path: String):
	var sectors_for_output = []
	for sector in output_sectors:
		var formatted_sector = {
			"name": sector["name"],
			"height": sector["height"],
			"points": _format_inline_array(sector["points"]),
			"tiles": _format_inline_array(sector["tiles"])
		}
		sectors_for_output.append(formatted_sector)

	var json_text := "[\n"
	for i in sectors_for_output.size():
		var s = sectors_for_output[i]
		json_text += "\t{\n"
		json_text += "\t\t\"name\": \"%s\",\n" % s["name"]
		json_text += "\t\t\"height\": %.1f,\n" % s["height"]
		json_text += "\t\t\"points\": %s,\n" % s["points"]
		json_text += "\t\t\"tiles\": %s\n" % s["tiles"]
		if i == sectors_for_output.size() - 1:
			json_text += "\t}\n"
		else:
			json_text += "\t},\n"
	json_text += "]"

	var f := FileAccess.open(file_path, FileAccess.WRITE)
	f.store_string(json_text)
	f.close()

# --- Funkcja pomocnicza: konwertuje [[x,y], [x,y]] do jednej linii ---
func _format_inline_array(array_2d: Array) -> String:
	var str := "["
	for i in array_2d.size():
		var pair = array_2d[i]
		str += "[%d, %d]" % [pair[0], pair[1]]
		if i != array_2d.size() - 1:
			str += ", "
	str += "]"
	return str
