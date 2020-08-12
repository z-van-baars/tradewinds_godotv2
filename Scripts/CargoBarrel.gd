extends Node2D

var cargo = {}
var artikels
var selected

signal hovered
signal unhovered
signal clicked

func _ready():
	artikels = get_tree().root.get_node("Main/Artikels")
	for _artikel in artikels.artikel_list:
		cargo[_artikel] = 0


func connect_signals(player_node, info_card, dispatch_node):
	self.connect(
		"hovered",
		info_card,
		"_on_Entity_hovered")
	self.connect(
		"unhovered",
		info_card,
		"_on_Entity_unhovered")

func _on_BBox_input_event(viewport, event, shape_idx):
	pass # Replace with function body.


func _on_BBox_mouse_entered():
	$SelectionBox.visible = true
	emit_signal(
		"hovered",
		1,
		[])


func _on_BBox_mouse_exited():
	if not selected:
		$SelectionBox.visible = false
	emit_signal("unhovered")
