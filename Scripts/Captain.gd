extends "res://Scripts/Character.gd"
var captains
var message_log
var home_city
var destination_city = null
var state = "Idle"
var rng = RandomNumberGenerator.new()

func _ready():
	._ready()
	rng.randomize()
	$WanderTimer.wait_time = rng.randf_range(0.5, 5.5)
	$WanderTimer.start()
	captains = get_tree().root.get_node("Main/Captains")
	message_log = get_tree().root.get_node("Main/UILayer/MessageLogDisplay")

func _process(delta):
	$Ship.state = state
	for city in recently_visited.keys():
		if get_tree().root.get_node("Main/Calendar").t_days - recently_visited[city][0] > 60:
			var text = name_str + " erased records of his visit to " + city.name_str
			get_tree().root.get_node("Main/UILayer/MessageLogDisplay").new_message(text)
			recently_visited.erase(city)
	
func wander():
	var biome_map = get_tree().root.get_node("Main/WorldGen/BiomeMap")
	var nearby_tiles = tools.get_nearby_tiles(
		biome_map.world_to_map($Ship.position), 10)
	var nearby_water_tiles = tools.filter_tiles(nearby_tiles, true)
	var random_target_tile = tools.r_choice(nearby_water_tiles)
	var random_coords = biome_map.map_to_world(random_target_tile)
	$Ship.path_to(random_coords)

func transact():
	print("starting transaction")
	var cargo_escrow = {}

	for i in range(5):
		var no_goods = true
		var cheapest_good = [99999, null]
		for _artikel in destination_city.cargo:
			if (destination_city.get_price(_artikel) < cheapest_good[0]
				and destination_city.cargo[_artikel] > 0):
				no_goods = false
				cheapest_good = [destination_city.get_price(_artikel), _artikel]
		if no_goods == true:
			continue
		if cargo_escrow.has(cheapest_good[1]):
			cargo_escrow[cheapest_good[1]] += 1
		else:
			cargo_escrow[cheapest_good[1]] = 1
		destination_city.increment_cargo(cheapest_good[1], -1)
	for each in $Ship.cargo.keys():
		if $Ship.cargo[each] > 0:
			var text = name_str + " sold " + str($Ship.cargo[each]) + " " + each
			message_log.new_message(text)
			destination_city.increment_cargo(each, $Ship.cargo[each])
			$Ship.cargo[each] = 0
	
	for each in cargo_escrow.keys():
		if cargo_escrow[each] == 0:
			continue
		var text = name_str + " bought " + str(cargo_escrow[each]) + " " + each
		message_log.new_message(text)
		$Ship.cargo[each] = cargo_escrow[each]
	destination_city = null
	print("finishing transaction")
	
	

func _on_WanderTimer_timeout():
	state = "Wander"
	wander()
	$WanderTimer.stop()
	$CityTimer.start()

func find_best_deal():
	var biggest_cargo = [0, null]
	for artikel in $Ship.cargo.keys():
		if $Ship.cargo[artikel] > biggest_cargo[0]:
			biggest_cargo = [$Ship.cargo[artikel], artikel]

	var best_deal = [0, null]
	for city in recently_visited.keys():
		if recently_visited[city][1][biggest_cargo[1]] > best_deal[0]:
			best_deal = [recently_visited[city][1][biggest_cargo[1]], city]

	return best_deal[1]

func _on_CityTimer_timeout():
	state = "Move"
	$CityTimer.stop()
	var dest_city
#	if recently_visited.keys().size() > 0 and $Ship.get_burthen() != 0:
#		dest_city = find_best_deal()
#	else:
#		dest_city = tools.r_choice(get_tree().root.get_node("Main/Cities").get_children())
	# SPAWNABLE CITIES WITH C KEY BRUH
	
	dest_city = tools.r_choice(get_tree().root.get_node("Main/Cities").get_children())
	$Ship.path_to(dest_city.get_center())
	$Ship.destination_city = dest_city
	destination_city = dest_city

func on_destination_reached():
	if destination_city == null:
		return
	var _text = name_str + " has arrived in " + destination_city.name_str.capitalize() + "."
	# message_log.new_message(text)
	state = "Transacting"
	print("Starting Transaction Timer")
	$TransactionTimer.wait_time = rng.randf_range(0.5, 2.5)
	$TransactionTimer.start()


func _on_TransactionTimer_timeout():
	print("Finished Transaction Timer")
	transact()
	$TransactionTimer.stop()
	$Ship.clear_destination_city()
	if randi()%100 < 30:
		$WanderTimer.wait_time = randi()%10
		$WanderTimer.start()
	else:
		$CityTimer.start()
