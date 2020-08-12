extends TextureRect

var artikels
var player
var sounds
var shift = false
var ctrl = false
var hovering = false
var dragging = false
var in_dump_zone = false
var in_take_zone = false
var artikel_label_scene = preload("res://Scenes/UI/ArtikelLabel.tscn")
var artikel_box_scene = preload("res://Scenes/UI/ArtikelBox.tscn")
var quantity_label_scene = preload("res://Scenes/UI/QuantityLabel.tscn")
var cargo_barrel_scene = preload("res://Scenes/Objects/CargoBarrel.tscn")
var items_to_dump = {}

func _ready():
	artikels = get_tree().root.get_node("Main/Artikels")
	player = get_tree().root.get_node("Main/Player")
	sounds = get_tree().root.get_node("Main/Sounds")
	reset_dump()


func reset_dump():
	for artikel in artikels.artikel_list:
		items_to_dump[artikel] = 0

func revert_dump():
	for artikel in items_to_dump:
		if items_to_dump[artikel] > 0:
			player.increment_cargo(artikel, items_to_dump[artikel])
	reset_dump()

func create_cargo_grid():
	for each in $ShipGrid.get_children():
		each.queue_free()
	var player_artikels_list = []
	
	for artikel in artikels.artikel_list:
		if player.get_cargo_quantity(artikel) > 0:
			player_artikels_list.append(artikel)

	for each in player_artikels_list:
		var new_box = artikel_box_scene.instance()
		$ShipGrid.add_child(new_box)
		new_box.load_artikel(
			each,
			player.get_cargo_quantity(each),
			-1)
		new_box.connect_signals(self)

func create_dump_grid():
	for each in $DumpGrid.get_children():
		each.queue_free()
	var to_dump_list = []
	
	for artikel in artikels.artikel_list:
		if items_to_dump[artikel] > 0:
			to_dump_list.append(artikel)

	for each in to_dump_list:
		var new_box = artikel_box_scene.instance()
		$DumpGrid.add_child(new_box)
		new_box.load_artikel(
			each,
			items_to_dump[each],
			-1,
			true)
		new_box.connect_signals(self)

func _input(event):
	if dragging == true:
		if event is InputEventMouseMotion:
			var menu_offset = -get_tree().root.get_node("Main/UILayer/LogisticsMenu").rect_position
			$DragBox.rect_position = get_viewport().get_mouse_position() + menu_offset - Vector2(2, 2)
		if event.is_action_released("left_click"):
			dragging = false
			$DragBox.hide()
			$DropTimer.start()
	else:
		if event is InputEventMouseMotion:
			# $HoverBox.rect_position = get_viewport().get_mouse_position() - rect_position
			# $HoverTimer.stop()
			# $HoverTimer.wait_time = 0.5
			# $HoverBox.hide()
			pass
	if event.is_action_pressed("left_shift"):
		shift = true
	elif event.is_action_pressed("left_control"):
		ctrl = true
	elif event.is_action_released("left_shift"):
		shift = false
	elif event.is_action_released("left_control"):
		ctrl = false

func transfer_goods(artikel_str, q, taking):
	if taking == false:
		items_to_dump[artikel_str] += q
		assert(items_to_dump[artikel_str] >= 0)
		player.increment_cargo(artikel_str, -q)
	elif taking == true:
		items_to_dump[artikel_str] -= q
		assert(items_to_dump[artikel_str] >= 0)
		player.increment_cargo(artikel_str, q)
	create_cargo_grid()
	create_dump_grid()

		

func _on_ArtikelBox_hovered():
	hovering = true
	sounds.get_node("UI/Flick_1").play()

func _on_ArtikelBox_unhovered():
	hovering = false

func _on_ArtikelBox_clicked(artikel_box_node, left_click):
	var q = 1

	if shift == true:
		sounds.get_node("UI/Drop_4").play()
		q = 5
		if left_click == false:
			for _i in range(5):
				transfer_goods(artikel_box_node.artikel_str, 1, artikel_box_node.taking)
			return
	if ctrl == true:
		q = artikel_box_node.quantity
		if left_click == false:
			sounds.get_node("UI/Drop_3").play()
			sounds.get_node("UI/Drop_4").play()
			for _i in range(artikel_box_node.quantity):
				transfer_goods(artikel_box_node.artikel_str, 1, artikel_box_node.taking)
			return
	if left_click == false:
		sounds.get_node("UI/Drop_4").play()
		transfer_goods(artikel_box_node.artikel_str, 1, artikel_box_node.taking)
		return
	q = min(q, artikel_box_node.quantity)
	dragging = true
	sounds.get_node("UI/Pickup_1").play()
	# $HoverTimer.stop()
	# $HoverBox.hide()
	$DragBox.load_artikel(artikel_box_node.artikel_str, q, artikel_box_node.taking)
	var menu_offset = -get_tree().root.get_node("Main/UILayer/LogisticsMenu").rect_position
	$DragBox.rect_position = get_viewport().get_mouse_position() + menu_offset - Vector2(2, 2)
	$DragBox.show()
	$DragBox/Backing.show()

func drop_goods():
	if in_dump_zone:
		if $DragBox.taking == false:
			for q in range($DragBox.quantity):
				transfer_goods(
					$DragBox.artikel_str,
					1,
					$DragBox.taking)
	if in_take_zone:
		if $DragBox.taking == true:
			for q in range($DragBox.quantity):
				transfer_goods(
					$DragBox.artikel_str,
					1,
					$DragBox.taking)

func _on_DumpButton_pressed():
	sounds.get_node("UI/Splash_1").play()
	sounds.get_node("UI/Drop_4").play()
	sounds.get_node("UI/Drop_3").play()
	var new_barrel = cargo_barrel_scene.instance()
	get_tree().root.get_node("Main/Objects").add_child(new_barrel)
	new_barrel.connect_signals(
		player,
		get_tree().root.get_node("Main/UILayer/InfoCard"),
		get_tree().root.get_node("Main/Dispatcher"))
	new_barrel.position = player.get_node("Ship").position
	for artikel_type in items_to_dump:
		if items_to_dump.has(artikel_type) and items_to_dump[artikel_type] > 0:
			new_barrel.cargo[artikel_type] = items_to_dump[artikel_type]
			
	items_to_dump = {}
	reset_dump()
	create_cargo_grid()
	create_dump_grid()

func _on_DropTimer_timeout():
	drop_goods()
	sounds.get_node("UI/Drop_1").play()

func _on_DumpPanel_mouse_entered():
	in_dump_zone = true

func _on_DumpPanel_mouse_exited():
	in_dump_zone = false

func _on_CargoPanel_mouse_entered():
	in_take_zone = true

func _on_CargoPanel_mouse_exited():
	in_take_zone = false


func _on_ResetButton_pressed():
	revert_dump()
	create_cargo_grid()
	create_dump_grid()


func _on_XButton_pressed():
	revert_dump()

