extends Panel

var city_header = Color(255, 207, 104)
var tile_debug = false

func _process(delta):
	rect_position = get_viewport().get_mouse_position()
	if tile_debug == true:
		var mouse_pos = get_viewport().get_mouse_position()
		var adjusted_pos = get_viewport().get_canvas_transform().xform_inv(mouse_pos)
		var selected_tile = get_tree().root.get_node("Main/WorldGen/BiomeMap").world_to_map(adjusted_pos)
		load_tile(selected_tile)

func _on_Entity_hovered(entity_type, stats):
	visible = true
	if entity_type == 0:
		$EntityName.text = stats[0].capitalize()
		$EntityName.visible = true
		$LordLabel.text = "Lord - " + stats[1]
		$LordLabel.visible = true
		$PopLabel.text = "Pop - " + str(stats[2])
		$PopLabel.visible = true
		$ProductionLabel.visible = true
		$ProductionLabel.text = ""
		for each in stats[3]:
			if stats[3][each] > 0:
				$ProductionLabel.text += each + "  " + str(stats[3][each]) + "   "
		rect_size = Vector2(262, 240)
	elif entity_type == 1:
		$EntityName.text = stats[0].capitalize()
		$EntityName.visible = true
		$CaptainLabel.text = "Captain - Unknown"
		$CaptainLabel.visible = true
		$HullLabel.text = "Ship Class - " + stats[1].capitalize()
		$HullLabel.visible = true
		$SpeedLabel.text = "Speed - " + str(stats[2])
		$SpeedLabel.visible = true
		$StateLabel.text = "State - " + stats[3]
		$StateLabel.visible = true
	elif entity_type == 2:
		$EntityName.text = "Cargo Barrel"
		$EntityName.visible = true
		$CaptainLabel.text = "Unknown Contents"
		$CaptainLabel.visible = true

func _on_Entity_unhovered():
	visible = false
	for each in get_children():
		each.visible = false

func load_tile(tile):
	visible = true
	$EntityName.text = get_tree().root.get_node("Main/WorldGen").biomemap[tile.y][tile.x]
	$EntityName.visible = true
	$TerrainLabel.text = str(get_tree().root.get_node("Main/WorldGen").terrain_map[tile.y][tile.x])
	$TerrainLabel.visible = true
	$PositionLabel.text = "Position [" + str(tile.x) + ", " + str(tile.y) + "]"
	$PositionLabel.visible = true
	$ElevationLabel.text = "Elevation: "
	$ElevationLabel.text += str(get_tree().root.get_node("Main/WorldGen").heightmap[tile.y][tile.x])
	$ElevationLabel.visible = true
	$FluxLabel.text = str(get_tree().root.get_node("Main/WorldGen").waterflux_map[tile.y][tile.x])
	$FluxLabel.visible = true

func unload_tile():
	$EntityName.visible = false
	$TerrainLabel.visible = false
	$PositionLabel.visible = false
	$ElevationLabel.visible = false
	$FluxLabel.visible = false
	
	visible = false
