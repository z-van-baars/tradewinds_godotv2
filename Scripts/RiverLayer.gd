extends Node2D
var tools: Node
var biome_map
var waterflux_map: Array
var watersource_map: Array
var river_threshold
var river_scene = preload("res://Scenes/RiverTile.tscn")

func set_maps():
	tools = get_tree().root.get_node("Main/Tools")
	biome_map = get_tree().root.get_node("Main/WorldGen/BiomeMap")
	waterflux_map = get_tree().root.get_node("Main/WorldGen").waterflux_map
	watersource_map = get_tree().root.get_node("Main/WorldGen").watersource_map
	river_threshold = get_tree().root.get_node("Main/WorldGen").river_threshold


func create_river_nodes():
	set_maps()
	print("Placing Rivers")
	var x = 0
	var y = 0
	for row in waterflux_map:
		x = 0
		for tile in row:
			if tile[1] > river_threshold:
				var new_river = river_scene.instance()
				add_child(new_river)
				new_river.position = biome_map.map_to_world(Vector2(x, y))
				new_river.set_visibility(
					watersource_map[y][x][0],
					watersource_map[y][x][1])
			x += 1
		y += 1

			
