extends Panel

var city_header = Color(255, 207, 104)

func _process(delta):
	rect_position = get_viewport().get_mouse_position()

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

func _on_Entity_unhovered():
	visible = false
	for each in get_children():
		each.visible = false
