extends Node2D

var camera
var tools
var seanav

signal toggle_logistics_menu
signal open_city_menu

var spawn_mode = false
var teleport_mode = false
var cityspawn_mode = false
var tile_debug = false

var artikels
var own_ship_selected = false
var ship_selected = null

var silver = 100

var name_str = "Player"

var cargo_barrel_scene = preload("res://Scenes/Objects/CargoBarrel.tscn")

func _ready():
	tools = get_tree().root.get_node("Main/Tools")
	artikels = get_tree().root.get_node("Main/Artikels")
	seanav = get_tree().root.get_node("Main/WorldGen/SeaNavMap")
	camera = $Ship/Camera2D
	camera.current = true
	$Ship.initialize_stats("cog", true, self)
	$Ship.connect_signals(
		self,
		get_tree().root.get_node("Main/UILayer/InfoCard"),
		get_tree().root.get_node("Main/Dispatcher"))
	$Ship/Flag.texture = load("res://Assets/Flags/green.png")

	for _artikel in artikels.artikel_list:
		$Ship.cargo[_artikel] = 0
	$Ship.cargo["Salted Beef"] = 3
	$Ship.cargo["Rum"] = 2
	$Ship.cargo["Bread"] = 5
	$Ship.generate_random_officers()


func make_random_cargo_barrels(b):
	for barrel in range(b):
		var new_barrel = cargo_barrel_scene.instance()
		get_tree().root.get_node("Main/Objects").add_child(new_barrel)
		new_barrel.connect_signals(
			self,
			get_tree().root.get_node("Main/UILayer/InfoCard"),
			get_tree().root.get_node("Main/Dispatcher"))
		var random_offset = Vector2(randi()%100 - 50, randi()%100 - 50)
		new_barrel.position = $Ship.position + random_offset
		var random_artikel = tools.r_choice(artikels.artikel_list)
		new_barrel.cargo[random_artikel] = randi()%100
	

func randomize_start(cities):
	var r_city = tools.r_choice(cities.get_children())
	var neighbor_tiles = tools.get_neighbor_tiles(r_city.map_tile)
	# filter tiles around a random start city for water only
	var f_neighbor_tiles = tools.filter_tiles(neighbor_tiles, true)
	var r_start = tools.r_choice(f_neighbor_tiles)
	$Ship.position = get_tree().root.get_node("Main/WorldGen/BiomeMap").map_to_world(r_start)
	$Ship.position.y += 32

func get_ship_pos():
	return $Ship.position

func get_cargo_quantity(artikel_name):
	return $Ship.cargo[artikel_name]

func increment_cargo(artikel_name, quantity):
	$Ship.cargo[artikel_name] += quantity

func increment_silver(quantity):
	silver += quantity

func _on_City_right_click(city_node):
	if own_ship_selected != true:
		return
	
	$Ship.destination_city = city_node
	$Ship.path_to(city_node.get_center())

func _on_Entity_right_click(entity_node):
	if own_ship_selected != true:
		return
	$Ship.target_entity = entity_node

func _on_Ship_left_click(ship_node):
	ship_selected = ship_node
	ship_node.select()
	own_ship_selected = ship_node.player_ship

func _on_Ship_right_click(ship_node):
	if ship_node != $Ship:
		$Ship.target_entity = ship_node

func _on_Ship_destination_reached(destination_city):
	emit_signal("open_city_menu", destination_city)
	$Ship.clear_destination_city()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("F11"):
		OS.window_fullscreen = !OS.window_fullscreen
	elif event.is_action_pressed("logistics_key"):
		emit_signal("toggle_logistics_menu")
	elif event.is_action_pressed("ui_zoom"):
		if camera.zoom.x == 1:
			camera.zoom.x = 2
			camera.zoom.y = 2
		elif camera.zoom.x == 2:
			camera.zoom.x = 4
			camera.zoom.y = 4
		elif camera.zoom.x == 4:
			camera.zoom.x = 8
			camera.zoom.y = 8
		elif camera.zoom.x == 8:
			camera.zoom.x = 1
			camera.zoom.y = 1
	elif event.is_action_pressed("spawn_key"):
		get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").visible = true
		get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").text = "Spawn Mode"
		spawn_mode = true
	elif event.is_action_released("spawn_key"):
		get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").visible = false
		get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").text = "Paused"
		spawn_mode = false
	elif event.is_action_pressed("tile_debug_key"):
		if tile_debug == false:
			get_tree().root.get_node("Main/WorldGen/TileSelector").show()
			get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").visible = true
			get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").text = "Tile Debug Mode"
			get_tree().root.get_node("Main/UILayer/InfoCard").tile_debug = true
			tile_debug = true
		else:
			get_tree().root.get_node("Main/WorldGen/TileSelector").hide()
			get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").visible = false
			get_tree().root.get_node("Main/UILayer/InfoCard").tile_debug = false
			get_tree().root.get_node("Main/UILayer/InfoCard").unload_tile()
			tile_debug = false

	elif event.is_action_pressed("teleport"):
		teleport_mode = !teleport_mode
		if teleport_mode == true:
			get_tree().root.get_node("Main/UILayer/MapWidget/TeleportIndicator").show()
		elif teleport_mode == false:
			get_tree().root.get_node("Main/UILayer/MapWidget/TeleportIndicator").hide()
	elif event.is_action_pressed("cityspawn_key"):
		cityspawn_mode = !cityspawn_mode
		if cityspawn_mode == true:
			get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").visible = true
			get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").text = "City Spawn Mode"
			get_tree().root.get_node("Main/UILayer/MapWidget/CitySpawnIndicator").show()
			get_tree().root.get_node("Main/WorldGen/TileSelector").show()
		elif cityspawn_mode == false:
			get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").visible = false
			get_tree().root.get_node("Main/UILayer/MapWidget/CitySpawnIndicator").hide()
			get_tree().root.get_node("Main/WorldGen/TileSelector").hide()
	elif event.is_action_pressed("boost_key"):
		if $Ship.speed == 75:
			get_tree().root.get_node("Main/UILayer/MapWidget/BoostIndicator").show()
			$Ship.speed = 500
		elif $Ship.speed == 500:
			$Ship.speed = 75
			get_tree().root.get_node("Main/UILayer/MapWidget/BoostIndicator").hide()
#	elif event.is_action_pressed("scrollwheel_up"):
#		var zoom_pos = get_global_mouse_position()
#		camera.zoom.x -= 1
#		camera.zoom.y -= 1
#		camera.zoom.x = round(camera.zoom.x)
#		camera.zoom.y = round(camera.zoom.y)
#	elif event.is_action_pressed("scrollwheel_down"):
#		var zoom_pos = get_global_mouse_position()
#		camera.zoom.x += 1
#		camera.zoom.y += 1
#		camera.zoom.x = round(camera.zoom.x)
#		camera.zoom.y = round(camera.zoom.y)
	elif event.is_action_pressed("left_click") and tile_debug == true:
		var new_target = get_viewport().get_canvas_transform().xform_inv(event.position)
		var adjusted_target = new_target * camera.zoom * camera.zoom
		var selected_tile = get_tree().root.get_node("Main/WorldGen/BiomeMap").world_to_map(adjusted_target)
		get_tree().root.get_node("Main/UILayer/InfoCard").load_tile(selected_tile)
	if own_ship_selected == true:
		if event.is_action_pressed("right_click"):
			var new_target = get_viewport().get_canvas_transform().xform_inv(event.position)
			var adjusted_target = new_target * camera.zoom * camera.zoom
			if teleport_mode == true:
				$Ship.position = adjusted_target
				$Ship.final_target = adjusted_target
				return
			$Ship.path_to(adjusted_target)

				
			
		elif event.is_action_pressed("left_click"):
			if ship_selected != null:
				ship_selected.deselect()
				ship_selected = null
				own_ship_selected = false

	elif own_ship_selected == false and ship_selected:
		if event.is_action_pressed("left_click"):
			if ship_selected != null:
				ship_selected.deselect()
				ship_selected = null
				own_ship_selected = false

	elif own_ship_selected == false and ship_selected == null:
		if event.is_action_pressed("left_click") and spawn_mode == true and cityspawn_mode == false:
			var world_pos = get_viewport().get_canvas_transform().xform_inv(event.position)
			get_tree().root.get_node("Main/Captains").spawn_captain(world_pos)
		elif event.is_action_pressed("left_click") and spawn_mode == false and cityspawn_mode == true:
			print("doing some business")
			var click_pos = get_viewport().get_canvas_transform().xform_inv(event.position)
			var adjusted_click_pos = click_pos * camera.zoom * camera.zoom
			var tile = get_tree().root.get_node("Main/WorldGen/BiomeMap").world_to_map(adjusted_click_pos)
			if get_tree().root.get_node("Main/Cities").check_for_city(tile) == true:
				return
			elif get_tree().root.get_node("Main/Cities").check_for_city(tile) == false:
				print("attempting to make a city")
				get_tree().root.get_node("Main/Cities").new_city(tile)
				return




