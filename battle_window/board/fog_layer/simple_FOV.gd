@tool
extends Resource
class_name SimpleFOV

# === Parametry konfiguracji FOV ===
@export_range(0.5, 3.0, 0.001) var visibility_factor :float = 1.666:
	set(val):
		visibility_factor = val
		_notify_change()

@export_range(0.0, 5.0, 0.01) var tol_min :float = 1.0:
	set(val):
		tol_min = val
		_notify_change()

@export_range(0.0, 5.0, 0.01) var tol_max :float = 3.0:
	set(val):
		tol_max = val
		_notify_change()

@export_range(0.0, 1.0, 0.01) var tol_k :float = 0.1:
	set(val):
		tol_k = val
		_notify_change()

@export_range(0.0, 2.0, 0.01) var height_bonus :float = 0.0:
	set(val):
		height_bonus = val
		_notify_change()

@export_range(0.0, 5.0, 0.01) var shadow_penalty :float = 3.5:
	set(val):
		shadow_penalty = val
		_notify_change()

@export_range(0.0, 1.0, 0.01) var symmetry_factor :float = 0.1:
	set(val):
		symmetry_factor = val
		_notify_change()

# === Dane mapy i widoczności ===
var size: Vector2i = Vector2i(0, 0)
var fov := {}
var height_map := {}

# === Publiczne API ===
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
	fov[origin] = true  # zawsze widzisz siebie

	for dx in range(-max_range, max_range + 1):
		for dy in range(-max_range, max_range + 1):
			var pos = origin + Vector2i(dx, dy)
			if not _in_bounds(pos):
				continue

			var distance = origin.distance_to(pos)
			if distance == 0.0 or distance > max_range:
				continue

			var target_h = height_map.get(pos, 0)
			var target_pitch = float(target_h - origin_h) / distance

			var max_pitch = -INF
			var points = _bresenham_line(origin, pos)

			for p in points:
				if p == origin or p == pos:
					continue
				if not height_map.has(p):
					continue

				var h = height_map[p]
				var d = origin.distance_to(p)
				if d == 0.0:
					continue

				var pitch = float(h - origin_h) / d
				if pitch > max_pitch:
					max_pitch = pitch

			# Tolerancja większa przy większym dystansie
			var tolerance = 3.0 / distance
			if target_pitch >= max_pitch - tolerance:
				fov[pos] = true



# === Widoczność oparta na wysokości (w obie strony) ===
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

		var mid = (ha + hb) * 0.5
		var gradient = ((hb - ha) * visibility_factor) * (d / total_d)
		var h_line = ha + gradient

		# Poprawki widzenia zza rogów / osłon
		if hb > ha:
			h_line -= height_bonus
		elif hb < ha:
			h_line += shadow_penalty

		h_line = lerp(h_line, mid, symmetry_factor)

		var tol = _tolerance(d)
		var is_near_target := p.distance_to(b) <= 1.5

		if float(h_obs) > float(h_line) + tol:
			return false

	# Jeśli żadna przeszkoda nie zablokowała widoku — zwróć true
	return true


# === Tolerancja w zależności od dystansu ===
func _tolerance(distance: float) -> float:
	return clamp(tol_min + distance * tol_k, tol_min, tol_max)

# === Bresenham (linie widzenia) ===
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

# === Granice mapy ===
func _in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < size.x and pos.y < size.y

# === Auto-refresh przy zmianach w edytorze ===
func _notify_change():
	if Engine.is_editor_hint():
		var fog_layer = get_meta("fog_layer")
		if fog_layer and fog_layer.has_method("_refresh_fog"):
			fog_layer._refresh_fog()
