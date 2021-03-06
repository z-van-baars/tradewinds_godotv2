extends TextureRect
var sounds

var player
var ship

var dragging = false
var drag_offset = Vector2(0, 0)
var tabs

func _ready():
	sounds = get_tree().root.get_node("Main/Sounds")
	player = get_tree().root.get_node("Main/Player")
	ship = get_tree().root.get_node("Main/Player/Ship")
	tabs = [
		$ShipTab,
		$CargoTab,
		$OfficersTab,
		$CrewTab,
		$MoraleTab,
		$EquipmentTab]

func _process(delta):
	# Right now it's possible to drag the menu offscreen
	# so that it cannot be closed or exited
	# need to either:
	# 1 - bound dragging to screen size - menu size
	# 2 - remove menus that are offscreen
	# 3 - add manual way to close offscreen menus - keyboard shortcut esc
	if dragging:
		rect_position = get_global_mouse_position() - drag_offset

func reset_ship_tab():
	$ShipTab/ShipName.text = ship.ship_name
	$ShipTab/HullLabel.text = ship.hull.capitalize()
	$ShipTab/SpeedLabel.text = str(ship.speed)
	$ShipTab/CargoLabel.text = str(ship.get_burthen()) + " / " + str(ship.cargo_cap)

func reset_cargo_tab():
	$CargoTab.create_cargo_grid()
	$CargoTab.create_dump_grid()
	
func set_all():
	get_tree().paused = true
	recenter()
	reset_ship_tab()
	reset_cargo_tab()
	$OfficersTab.set_all(player)
	
	# $ShipSprite.texture = load("res://Ships/" + ship.hull + "/down_right_1.png")
	$ShipTab.show()

func recenter():
	var x = get_viewport().size.x / 2 - rect_size.x / 2
	var y = get_viewport().size.y / 2 - rect_size.y / 2
	rect_position = Vector2(x, y)

func close():
	get_tree().paused = false
	hide()

func _input(event):
	# in the future I might want to make esc do something other
	# than to just close the menu, for example if something is
	# selected
	if (event.is_action_pressed("logistics_key") 
		or event.is_action_pressed("ui_cancel")):
		_on_Player_toggle_logistics_menu()

func _on_DragButton_button_down():
	dragging = true
	drag_offset = get_global_mouse_position() - rect_position

func _on_DragButton_button_up():
	dragging = false
	drag_offset = Vector2(0, 0)

func _on_Player_toggle_logistics_menu():
	if visible:
		hide()
		sounds.get_node("UI/Click_2").play()
	else:
		set_all()
		show()
		sounds.get_node("UI/Click_2").play()

func hide_all():
	for each in tabs:
		each.hide()
	sounds.get_node("UI/PageTurn_1").play()


func _on_XButton_pressed():
	hide_all()
	close()
	sounds.get_node("UI/Click_2").play()

func _on_Button_hovered():
	sounds.get_node("UI/Flick_1").play()

func _on_ShipButton_pressed():
	hide_all()
	$ShipTab.show()
	sounds.get_node("UI/Click_1").play()


func _on_CargoButton_pressed():
	hide_all()
	$CargoTab.show()
	sounds.get_node("UI/Click_1").play()

func _on_OfficersButton_pressed():
	hide_all()
	$OfficersTab.show()
	sounds.get_node("UI/Click_1").play()

func _on_CrewButton_pressed():
	hide_all()
	$CrewTab.show()
	sounds.get_node("UI/Click_1").play()


func _on_MoraleButton_pressed():
	hide_all()
	$MoraleTab.show()
	sounds.get_node("UI/Click_1").play()


func _on_EquipmentButton_pressed():
	hide_all()
	$EquipmentTab.show()
	sounds.get_node("UI/Click_1").play()
