@tool
extends Resource
class_name SimpleFOV

@export_range(0.5, 3.0, 0.001)
var visibility_factor :float = 1.666
@export_range(0.0, 5.0, 0.01)
var tol_min :float = 1.0
@export_range(0.0, 5.0, 0.01)
var tol_max :float = 3.0
@export_range(0.0, 1.0, 0.01)
var tol_k :float = 0.045
@export_range(0.0, 2.0, 0.001)
var height_bonus :float = 0.0
@export_range(0.0, 5.0, 0.01)
var shadow_penalty :float = 3.5
@export_range(0.0, 1.0, 0.01)
var symmetry_factor :float = 0.1

var size: Vector2i
var fov := {}
var height_map := {}

func clear() -> void:
	fov.clear()

func set_height(pos: Vector2i, h: int) -> void:
	height_map[pos] = h

func is_in_view(pos: Vector2i) -> bool:
	return fov.has(pos)

func compute(origin: Vector2i, max_range: int = 50) -> void:
	clear()
	if not _in_bounds(origin):
		return

	var origin_h = height_map.get(origin, 0)
	fov[origin] = true

	for dx in range(-max_range, max_range + 1):
		for dy in range(-max_range, max_range + 1):
			var target = origin + Vector2i(dx, dy)
			if target == origin or not _in_bounds(target):
				continue

			var dist = origin.distance_to(target)
			if dist > max_range:
				continue

			if _line_of_sight(origin, target):
				fov[target] = true

func _line_of_sight(a: Vector2i, b: Vector2i) -> bool:
	# Obustronna widoczność: a->b i b->a dla lepszego odwzorowania The-West
	return _los_height_line(a, b) and _los_height_line(b, a)

func _los_height_line(a: Vector2i, b: Vector2i) -> bool:
	var ha = height_map.get(a, 0)
	var hb = height_map.get(b, 0)
	var points = _bresenham_line(a, b)
	if points.size() <= 2:
		return true

	var total_d = a.distance_to(b)
	if total_d <= 0.0:
		return true

	for i in range(1, points.size() - 1):
		var p: Vector2i = points[i]
		var h_obs = height_map.get(p, 0)
		var d = a.distance_to(p)

		# Wysokość linii widoczności
		var mid = (ha + hb) * 0.5
		var gradient = ((hb - ha) * visibility_factor) * (d / total_d)
		var h_line = ha + gradient

		# Korekty w zależności od kierunku obserwacji
		if hb > ha:
			h_line -= height_bonus
		elif hb < ha:
			h_line += shadow_penalty

		h_line = lerp(h_line, mid, symmetry_factor)

		# Sprawdzenie, czy przeszkoda zasłania linię widoczności
		var tol = _tolerance(d)
		if float(h_obs) > float(h_line) + tol:
			return false

	return true

func _tolerance(distance: float) -> float:
	return clamp(tol_min + distance * tol_k, tol_min, tol_max)

func _bresenham_line(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	var x0 = from.x
	var y0 = from.y
	var x1 = to.x
	var y1 = to.y
	var dx = abs(x1 - x0)
	var dy = -abs(y1 - y0)
	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1
	var err = dx + dy

	while true:
		points.append(Vector2i(x0, y0))
		if x0 == x1 and y0 == y1:
			break
		var e2 = 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy

	return points

func _in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < size.x and pos.y < size.y
