@tool
extends Resource
class_name SimpleFOV

@export var eye_height : float = 1.8

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

	var origin_h = height_map.get(origin, 0)
	var origin_z = origin_h + eye_height
	fov[origin] = true

	for dx in range(-max_range, max_range + 1):
		for dy in range(-max_range, max_range + 1):
			var target = origin + Vector2i(dx, dy)
			if target == origin or not _in_bounds(target):
				continue

			var dist = origin.distance_to(target)
			if dist > max_range:
				continue

			debug_rays.append(_bresenham_2d(origin, target))

			var target_h = height_map.get(target, 0)
			var target_z = target_h + eye_height

			var los := _line_of_sight_3d_lerped(origin, origin_z, target, target_z) and _line_of_sight_3d_lerped(target, target_z, origin, origin_z)
			if los:
				fov[target] = true

func _line_of_sight_3d_lerped(from: Vector2i, from_z: float, to: Vector2i, to_z: float) -> bool:
	var path = _bresenham_3d_path(from, to, from_z, to_z)
	for point in path:
		var pos2d = Vector2i(point.x, point.y)
		if pos2d == from or pos2d == to:
			continue
		if not _in_bounds(pos2d):
			return false
		var terrain_z = height_map.get(pos2d, 0)
		if terrain_z > point.z + 0.01:
			return false
	return true

func _bresenham_3d_path(from: Vector2i, to: Vector2i, from_z: float, to_z: float) -> Array[Vector3]:
	var result: Array[Vector3] = []

	var x0 = from.x
	var y0 = from.y
	var x1 = to.x
	var y1 = to.y

	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var n = max(dx, dy)
	n = max(n, 1)

	for i in range(n + 1):
		var t = float(i) / float(n)

		# interpolacja w przestrzeni kafli, nie pixelowo
		var fx = lerp(float(x0) + 0.5, float(x1) + 0.5, t)
		var fy = lerp(float(y0) + 0.5, float(y1) + 0.5, t)

		# ZAMIANA: było round(), teraz jest floor()
		var xi = int(fx)
		var yi = int(fy)

		var zi = lerp(from_z, to_z, t)
		result.append(Vector3(xi, yi, zi))

	return result


func _bresenham_2d(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
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
