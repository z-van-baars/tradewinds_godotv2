extends TileMap


onready var astar_node = load("res://scripts/AstarMod.gd").new()

var map_width
var map_height

var path_start_position = Vector2()
var path_end_position = Vector2()

var obstacles

var _point_path = []
var _half_cell_size = Vector2()

var water_indexes = [
	28, 29, 30, 31,
	36, 37, 38, 39,
	40, 41, 42, 43]

func _ready():
	_half_cell_size = cell_size / 2

func initialize(biomemap, biome_tilemap):
	var start = OS.get_unix_time()
	map_width = biomemap[0].size()
	map_height = biomemap.size()
	print("Importing tiles from worldgen...")
	setup_tiles(biome_tilemap)
	var new_time = OS.get_unix_time() - start
	print(new_time % 60)
	print("Identifying navigable tiles...")
	obstacles = get_used_cells_by_id(0)
	new_time = OS.get_unix_time() - new_time
	print(new_time % 60)
	print("Adding navigable cells to internal array...")
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	new_time = OS.get_unix_time() - new_time
	print(new_time % 60)
	print("Adding navigable tile connections...")
	astar_connect_walkable_cells_diagonal(walkable_cells_list)
	new_time = OS.get_unix_time() - new_time
	print(new_time % 60)

func setup_tiles(biome_tilemap):
	for y in range(map_height):
		for x in range(map_width):
			if biome_tilemap.get_cellv(Vector2(x, y)) in water_indexes:
				set_cellv(Vector2(x, y), 1)
			else:
				set_cellv(Vector2(x, y), 0)

func path_to(start_tile, target_tile):
	var valid_start = _set_path_start_position(start_tile)
	var valid_end = _set_path_end_position(target_tile)
	if valid_start and valid_end:
		return recalculate_path()


func astar_add_walkable_cells(obstacles = []):
	var points_array = []
	for y in range(map_height):
		for x in range(map_width):
			var point = Vector2(x, y)
			if point in obstacles:
				continue
			
			points_array.append(point)
			var point_index = calculate_point_index(point)
			astar_node.add_point(point_index, Vector2(point.x, point.y))
	return points_array

func astar_connect_walkable_cells_diagonal(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y + 1),
			Vector2(point.x, point.y - 1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			if point_relative == point or is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			astar_node.connect_points(point_index, point_relative_index, true)

func recalculate_path():
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	return _point_path

func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_width or point.y >= map_height


func calculate_point_index(point):
	return point.x + map_width * point.y

func _set_path_start_position(value):
	if value in obstacles:
		return false
	if is_outside_map_bounds(value):
		return false
	
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		return true
	return false

func _set_path_end_position(value):
	if value in obstacles:
		return false
	if is_outside_map_bounds(value):
		return false

	path_end_position = value
	if path_start_position != value:
		return true
	return false
