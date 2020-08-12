extends KinematicBody2D

signal left_click
signal right_click
signal hovered
signal unhovered
signal target_entity_reached

var tools
var ships
var characters
var seanav
var seanav2d
var ship_stats
var selected = false
var is_ship = true

# constant stats, same for all ships
var cargo = {}
var last_direction = Vector2(0, 1)
var direction : Vector2
var step_target : Vector2
var final_target : Vector2
var path = []
var destination_city = null
var target_entity = null
var player_ship = false
var captain = null

# variable stats, filled out for different ships
var state = "Idle"
var ship_name
var hull
var speed
var cargo_cap
var officers = {}

func _ready():
	tools = get_tree().root.get_node("Main/Tools")
	ships = get_tree().root.get_node("Main/Ships")
	characters = get_tree().root.get_node("Main/Characters")
	seanav = get_tree().root.get_node("Main/WorldGen/SeaNavMap")
	seanav2d = get_tree().root.get_node("Main/SeaNav2D")
	ship_stats = get_tree().root.get_node("Main/ShipStats")

func initialize_stats(hull_class, is_player_ship, import_captain=null):
	ship_name = "The " + get_tree().root.get_node("Main/Ships").get_name()
	hull = hull_class
	speed = ship_stats.speed[hull_class]
	cargo_cap = ship_stats.cargo_cap[hull_class]
	final_target = position
	player_ship = is_player_ship
	if import_captain != null:
		captain = import_captain
	var officer_slots = ship_stats.get_officer_slots(hull_class)
	for os in officer_slots:
		if officer_slots[os] == true:
			officers[os] = null

func connect_signals(player_node, info_card, dispatch_node):
	self.connect(
		"left_click",
		player_node,
		"_on_Ship_left_click")
	self.connect(
		"right_click",
		player_node,
		"_on_Ship_right_click")
	self.connect(
		"hovered",
		info_card,
		"_on_Entity_hovered")
	self.connect(
		"unhovered",
		info_card,
		"_on_Entity_unhovered")
	self.connect(
		"target_entity_reached",
		dispatch_node,
		"_on_Ship_target_entity_reached")
	

func _draw():
	if path.size() > 0:
		var path_pts = []
		path_pts.append(position - position)
		path_pts.append(step_target - position)
		for each_point in path:
			path_pts.append(each_point - position)
		draw_polyline(path_pts, Color.red, 3)

func _process(delta):
	if target_entity != null:
		# Check if our target moved and repath if so
		if target_entity.position != final_target:
			path_to(target_entity.get_center())
	update()

func _physics_process(delta):
	if position == final_target:
		return
	# Do we have a path with at least 1 point remaining?
	if path.size() > 0:
		if position.distance_to(step_target) < 5:
			step_target = path[0]
			path.remove(0)
	else:
		step_target = final_target
		if position.distance_to(final_target) < 5:
			zero_target()

	direction = (step_target - position).normalized()
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()

	# Early Exit from Movement if we are at our target city
	if destination_city != null:
		if position.distance_to(destination_city.get_center()) < 50:
			emit_signal("target_entity_reached", self, destination_city)
			zero_target()
			clear_destination_city()
	
	# Early Exit from Movement if we have a target entity and are there
	elif destination_city == null and target_entity != null:
		if position.distance_to(target_entity.get_center()) < 15:
			emit_signal(
				"target_entity_reached",
				self,
				target_entity)
			zero_target()
			clear_target_entity()

	# move and junk
	var movement = speed * direction * delta
	move_and_collide(movement)
	animates_ship(direction)

func get_center():
	return Vector2(position.x, position.y + 3)

func zero_target():
	final_target = position
	path = []
	step_target = position

func get_burthen():
	var tons_burthen = 0

	for each in cargo.keys():
		tons_burthen += cargo[each]
	return tons_burthen

func generate_random_officers():
	for os in officers.keys():
		var new_character = characters.random_character()
		officers[os] = new_character
		new_character.title = os

func clear_destination_city():
	destination_city = null

func clear_target_entity():
	target_entity = null

func get_step_target():
	var new_step_target = seanav.map_to_world(path[0])
	path.remove(0)
	step_target = Vector2(new_step_target.x, new_step_target.y + 32)
	direction = (step_target - position).normalized()

func path_to(target_world_pos):
	var nav_path = seanav2d.get_simple_path(position, target_world_pos, false)
	if nav_path.size() < 1:
		return
	final_target = nav_path[nav_path.size()-1]
	set_path(nav_path)

func set_path(new_path):
	path = new_path
	step_target = path[0]
	path.remove(0)

func select():
	selected = true
	$SelectionBox.visible = true

func deselect():
	selected = false
	$SelectionBox.visible = false

func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.y >= 0.707:
		if norm_direction.x >= 0.3:
			return "downright"
		elif norm_direction.x <= -0.3:
			return "downleft"
		else:
			return "down"
	elif norm_direction.y <= -0.707:
		if norm_direction.x >= 0.3:
			return "upright"
		elif norm_direction.x <= -0.3:
			return "upleft"
		else:
			return "up"
	elif norm_direction.x <= -0.707:
		if norm_direction.y >= 0.3:
			return "downleft"
		elif norm_direction.y <= -0.3:
			return "upleft"
		else:
			return "left"
	elif norm_direction.x >= 0.707:
		if norm_direction.y >= 0.3:
			return "downright"
		elif norm_direction.y <= -0.3:
			return "upright"
		else:
			return "right"
	return "downright"

func animates_ship(direction: Vector2):
	if direction != Vector2.ZERO:
		# update last_direction
		last_direction = direction
		
		# Choose walk animation based on movement direction
		var animation = "sail_" + get_animation_direction(last_direction)
		
		# Play the walk animation
		$AnimatedSprite.play(animation)
	else:
		# Choose idle animation based on last movement direction and play it
		var animation = "sail_" + get_animation_direction(last_direction)
		$AnimatedSprite.play(animation)


func _on_BBox_mouse_entered():
	$SelectionBox.visible = true
	emit_signal(
		"hovered",
		1,
		[ship_name,
		 hull,
		 speed,
		 state])


func _on_BBox_mouse_exited():
	if not selected:
		$SelectionBox.visible = false
	emit_signal("unhovered")


func _on_BBox_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("left_click"):
		emit_signal("left_click", self)
	elif event.is_action_pressed("right_click"):
		emit_signal("right_click", self)
