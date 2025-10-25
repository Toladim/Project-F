class_name SimpleFOV
extends RefCounted

var size: Vector2i
var fov := {}
var height_map := {}

# Parametry bazujące na obserwacji działania The West
const VISIBILITY_FACTOR := 1.5 #narazie zostawic  # lekki "zapas" wysokości linii wzroku
const TOL_MIN := 2         #0.7    # minimalna tolerancja na stykach
const TOL_MAX := 5              # maksymalna tolerancja
const TOL_K   := 0.7           # narastanie tolerancji z dystansem

func _init(board_size: Vector2i) -> void:
	size = board_size
	clear()

func clear() -> void:
	fov.clear()

func set_height(pos: Vector2i, h: int) -> void:
	height_map[pos] = h

func is_in_view(pos: Vector2i) -> bool:
	return fov.has(pos)

# --- Główna funkcja licząca FOV z wymuszeniem symetrii ---
func compute(origin: Vector2i, max_range: int = 50) -> void:
	clear()
	if not _in_bounds(origin):
		return

	var origin_h = height_map.get(origin, 0)
	fov[origin] = true

	for dx in range(-max_range, max_range + 1):
		for dy in range(-max_range, max_range + 1):
			var target = origin + Vector2i(dx, dy)
			if target == origin:
				continue
			if not _in_bounds(target):
				continue

			var dist = origin.distance_to(target)
			if dist == 0.0 or dist > max_range:
				continue

			# 1) Oblicz LOS kierunkowy w obie strony (symetria)
			#    Widoczne tylko, jeśli linia wzroku jest wolna z obu stron.
			if _los_height_line(origin, target) and _los_height_line(target, origin):
				fov[target] = true

# --- LOS oparty o interpolację wysokości + tolerancję rosnącą z dystansem ---
func _los_height_line(a: Vector2i, b: Vector2i) -> bool:
	var ha = height_map.get(a, 0)
	var hb = height_map.get(b, 0)
	var points = _bresenham_line(a, b)
	if points.size() <= 2:
		return true

	var total_d = a.distance_to(b)
	if total_d <= 0.0:
		return true

	# Dla każdego pośredniego pola sprawdź czy nie "wystaje" ponad linię wzroku
	for i in range(1, points.size() - 1):
		var p: Vector2i = points[i]
		var h_obs = height_map.get(p, 0)
		var d = a.distance_to(p)

		# Interpolowana wysokość linii wzroku z lekkim zapasem (VISIBILITY_FACTOR)
		var h_line = ha + ((hb - ha) * VISIBILITY_FACTOR) * (d / total_d)
		# Tolerancja zależna od odległości (upraszcza efekt sigmoidy)
		var tol = _tolerance(d)

		# Jeśli przeszkoda jest wyżej niż linia wzroku + tolerancja → blokada
		if float(h_obs) > float(h_line) + tol:
			return false

	return true

func _tolerance(distance: float) -> float:
	# Prosta funkcja tolerancji rosnącej z dystansem (zamiennik sigmoidy)
	# Im dalej, tym większy bufor wymagany do "minięcia" krawędzi przeszkody.
	return clamp(TOL_MIN + distance * TOL_K, TOL_MIN, TOL_MAX)

# --- Bresenham (linia od A do B po siatce) ---
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
