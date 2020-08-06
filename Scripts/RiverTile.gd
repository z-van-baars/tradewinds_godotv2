extends Node2D


onready var spokes = {
		0: get_node("0"),
		1: get_node("1"),
		2: get_node("2"),
		3: get_node("3"),
		4: get_node("4"),
		5: get_node("5"),
		6: get_node("6"),
		7: get_node("7")}

func set_visibility(sources, output):
	for each in sources:
		spokes[each].show()
	if output != -1:
		spokes[output].show()
