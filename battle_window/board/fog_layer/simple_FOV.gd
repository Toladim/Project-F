@tool
extends Resource
class_name SimpleFOV

@export var eye_height : float = 1.0   # wysokość "oczu" ponad wysokością pola
@export var max_range : int = 50

var size: Vector2i
var fov: Dictionary = {}
var height_map: Dictionary = {}
var debug_rays: Array = []

func clear() -> void:
	fov.clear()
	debug_rays.clear()

func set_height(pos: Vector2i, h: float) -> void:
	height_map[pos] = h

func is_in_view(pos: Vector2i) -> bool:
	return fov.has(pos)

func compute(origin: Vector2i, max_range_override: int = -1) -> void:
	clear()
	if not _in_bounds(origin):
		return

	var r = max_range if max_range_override < 0 else max_range_override

	var origin_h: float = height_map.get(origin, 0.0)
	var origin_z: float = origin_h + eye_height

	fov[origin] = true

	for y in range(size.y):
		for x in range(size.x):
			var target = Vector2i(x, y)
			if target == origin:
				continue
			if origin.distance_to(target) > r:
				continue
			if not _in_bounds(target):
				continue

			var target_h: float = height_map.get(target, 0.0)
			var target_z: float = target_h + eye_height

			if _los_3d(origin, origin_z, target, target_z):
				fov[target] = true

func _los_3d(a: Vector2i, az: float, b: Vector2i, bz: float) -> bool:
	var pts = _bresenham_line(a, b)
	debug_rays.append(pts)

	var total = a.distance_to(b)
	if total <= 0.0:
		return true

	for i in range(1, pts.size() - 1):
		var p: Vector2i = pts[i]
		var t = float(i) / float(pts.size() - 1)   # interpolacja 0..1
		var line_z = lerp(az, bz, t)                # wysokość wzroku w tym punkcie
		var terrain_z = height_map.get(p, 0.0)

		if terrain_z > line_z:                      # rdzeń algorytmu FOV 3D
			return false

	return true

func _bresenham_line(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var pts: Array[Vector2i] = []
	var x0 = a.x
	var y0 = a.y
	var x1 = b.x
	var y1 = b.y
	var dx = abs(x1 - x0)
	var dy = -abs(y1 - y0)
	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1
	var err = dx + dy

	while true:
		pts.append(Vector2i(x0, y0))
		if x0 == x1 and y0 == y1:
			break
		var e2 = 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy

	return pts

func _in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < size.x and pos.y < size.y
