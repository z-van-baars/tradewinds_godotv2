extends Node2D

var name_str = "Cargo Barrel"
var cargo = {}
var artikels
var selected

var is_ship = false
var is_city = false

signal hovered
signal unhovered
signal clicked
signal right_click

func _ready():
	artikels = get_tree().root.get_node("Main/Artikels")
	for _artikel in artikels.artikel_list:
		cargo[_artikel] = 0
	
	$LifeTimer.wait_time = 360
	$LifeTimer.start()


func connect_signals(player_node, info_card, dispatch_node):
	self.connect(
		"hovered",
		info_card,
		"_on_Entity_hovered")
	self.connect(
		"unhovered",
		info_card,
		"_on_Entity_unhovered")
	self.connect(
		"right_click",
		player_node,
		"_on_Entity_right_click")

func increment_cargo(artikel_name, quantity):
	if cargo[artikel_name] == 0 and quantity < 0:
		return
	cargo[artikel_name] = max(0, cargo[artikel_name] + quantity)

func _on_BBox_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("right_click"):
		emit_signal("right_click", self)

func _on_BBox_mouse_entered():
	$SelectionBox.visible = true
	emit_signal(
		"hovered",
		2,
		[])

func get_center():
	return position

func _on_BBox_mouse_exited():
	if not selected:
		$SelectionBox.visible = false
	emit_signal("unhovered")


func _on_LifeTimer_timeout():
	$LifeTimer.stop()
	queue_free()
