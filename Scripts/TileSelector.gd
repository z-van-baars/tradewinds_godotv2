extends Sprite


func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var adjusted_pos = get_viewport().get_canvas_transform().xform_inv(mouse_pos)
	var selected_tile = get_tree().root.get_node("Main/WorldGen/BiomeMap").world_to_map(adjusted_pos)
	position = get_tree().root.get_node("Main/WorldGen/BiomeMap").map_to_world(selected_tile)
	position.y += 32
