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

var debug_rays: Array[Array] = []

func clear() -> void:
	fov.clear()
	debug_rays.clear()

func set_height(pos: Vector2i, h: int) -> void:
	height_map[pos] = h

func is_in_view(pos: Vector2i) -> bool:
	return fov.has(pos)

func compute(origin: Vector2i, max_range: int = 50) -> void:
	clear()
	if not _in_bounds(origin):
		return

	fov[origin] = true
	var origin_offsets := [
		Vector2(0.1, 0.1),
		Vector2(0.9, 0.1),
		Vector2(0.1, 0.9),
		Vector2(0.9, 0.9),
		Vector2(0.5, 0.1),
		Vector2(0.5, 0.9),
		Vector2(0.1, 0.5),
		Vector2(0.9, 0.5),
	]

	for dx in range(-max_range, max_range + 1):
		for dy in range(-max_range, max_range + 1):
			var target = origin + Vector2i(dx, dy)
			if target == origin or not _in_bounds(target):
				continue

			if origin.distance_to(target) > max_range:
				continue

			var visible := false

			for offset in origin_offsets:
				var from := origin + offset
				var to := target + Vector2(0.5, 0.5)  # celuj w środek pola
				debug_rays.append([from, to])
				if _los_vector(from, to):
					visible = true
					break

			if visible:
				fov[target] = true

func _los_vector(from: Vector2, to: Vector2) -> bool:
	var from_tile := from.floor()
	var to_tile := to.floor()

	var ha = height_map.get(from_tile, 0)
	var hb = height_map.get(to_tile, 0)

	var points := _dda_line(from, to, 64)
	if points.size() <= 2:
		return true

	var total_d = from.distance_to(to)
	if total_d <= 0.0:
		return true

	for i in range(1, points.size() - 1):
		var p = points[i]
		var grid_pos := p.floor()
		if not _in_bounds(grid_pos):
			continue

		var h_obs := height_map.get(grid_pos, 0)
		var d := from.distance_to(p)

		var mid := (ha + hb) * 0.5
		var gradient := ((hb - ha) * visibility_factor) * (d / total_d)
		var h_line := ha + gradient

		if hb > ha:
			h_line -= height_bonus
		elif hb < ha:
			h_line += shadow_penalty

		h_line = lerp(h_line, mid, symmetry_factor)

		var tol := _tolerance(d)
		if float(h_obs) > float(h_line) + tol:
			return false

	return true

func _dda_line(from: Vector2, to: Vector2, steps := 64) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var delta := to - from
	for i in range(steps + 1):
		var t := float(i) / steps
		points.append(from + delta * t)
	return points

func _tolerance(distance: float) -> float:
	return clamp(tol_min + distance * tol_k, tol_min, tol_max)

func _in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < size.x and pos.y < size.y
