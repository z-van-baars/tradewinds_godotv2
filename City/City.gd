extends Node2D

signal hovered
signal unhovered
signal left_click
signal right_click

var tools
var biome_map
var city_tilemap
var artikels

var map_tile

var city_name = "~"
var portrait_id = randi()%3+0
var size = (randi()%10+1)
var population = size * 1000
var growth_counter = 0
var growth_cap = size * size * 10

var neighborhood = []
var coastal_neighbors = []
var prioritized_tiles = []

var artikel_supply = {}
var artikel_price = {}
var demand_for = {}
var demand_last = {}
var production_last = {}

var water_indexes = [
	28, 29, 30, 31,
	36, 37, 38, 39,
	40, 41, 42, 43]

func initialize():
	city_name = get_tree().root.get_node("Main/Cities").get_name()
	tools = get_tree().root.get_node("Main/Tools")
	biome_map = get_tree().root.get_node("Main/WorldGen/BiomeMap")
	artikels = get_tree().root.get_node("Main/Artikels")
	set_bounding_box()
	neighborhood = tools.get_nearby_tiles(map_tile, 3 + int(size / 3))
	for each in neighborhood:
		if biome_map.get_cellv(each) in water_indexes:
			coastal_neighbors.append(each)
	resort_neighborhood()
	init_cargo()
	init_demand()
	set_demand_price()
	set_label()

func set_label():
	$BBox/Label/NameLabel.text = city_name.capitalize()

func increment_cargo(artikel_name, quantity):
	if artikel_supply[artikel_name] == 0 and quantity < 0:
		# print("No " + artikel_name + " to sell!")
		return
	artikel_supply[artikel_name] = max(0, artikel_supply[artikel_name] + quantity)

func get_cargo_quantity(artikel_name):
	return artikel_supply[artikel_name]

func init_cargo():
	for _artikel in artikels.artikel_list:
		artikel_supply[_artikel] = 0

func init_demand():
	for _artikel in artikels.artikel_list:
		demand_for[_artikel] = 0
		demand_last[_artikel] = 0

func clear_demand():
	for _artikel in artikels.artikel_list:
		demand_for[_artikel] = 0

func random_production():
	production_last = {}
	for artikel in artikels.artikel_list:
		production_last[artikel] = 0
	for j in range(size):
		var tile_to_work = tools.r_choice(neighborhood)
		var artikels_produced = work_tile(tile_to_work)
		for artikel in artikels_produced.keys():
			production_last[artikel] += artikels_produced[artikel]

func resort_neighborhood():
	prioritized_tiles = sort_by_food()

func production():
	production_last = {}
	for artikel in artikels.artikel_list:
		production_last[artikel] = 0
	
	var available_tiles = []
	for each in prioritized_tiles:
		available_tiles.append(biome_map.get_cellv(each[1]))
	
	for i in range(size):
		var tile_to_work = available_tiles.pop_front()
		work_tile(tile_to_work)
		

func sort_by_food():
	var tiles_by_food = []
	for tile in neighborhood:
		var total_food = artikels.total_food(biome_map.get_cellv(tile))
		var list_index = 0
		for other_tile in tiles_by_food:
			if total_food < other_tile[0]:
				list_index += 1
				continue
			break
		tiles_by_food.insert(list_index, [total_food, tile])
	return tiles_by_food

func work_tile(tile):
	var artikels_to_produce = artikels.get_production(tile)
	for artikel_to_produce in artikels_to_produce.keys():
		var q = artikels_to_produce[artikel_to_produce]
		increment_cargo(artikel_to_produce, q)
	return artikels_to_produce

func find_price(_artikel):
	var base = artikels.base_price[_artikel]
	var q = get_cargo_quantity(_artikel)
	var d = max(demand_for[_artikel], 1)

	var d_price = base
	d_price += sqrt(d) * base * 0.01
	d_price -= sqrt(q) * base * 0.01
	d_price = max(1, d_price)
	return int(d_price)

func set_demand_price(artikel=null):
	if artikel:
		artikel_price[artikel] = get_price(artikel)
		return
	for _artikel in artikels.artikel_list:
		artikel_price[_artikel] = find_price(_artikel)

func most_artikel(tile_list, desired_artikel):
	var most_artikel = [0, null]
	for tile in tile_list:
		if artikels.get_production(tile)[desired_artikel] > most_artikel[0]:
			most_artikel = [artikels.flat_production(tile)[desired_artikel], tile]
	return most_artikel[1]

func most_wealth(tile_list):
	var most_wealth = [0, null]
	for tile in tile_list:
		if artikels.total_wealth(tile) > most_wealth[0]:
			most_wealth = [artikels.total_wealth(tile), tile]
	return most_wealth[1]

func most_food(tile_list):
	var most_food = [0, null]
	for tile in tile_list:
		if artikels.total_food(tile) > most_food[0]:
			most_food = [artikels.total_food(tile), tile]
	return most_food[1]

func set_demand():
	clear_demand()
	for _artikel in artikels.foods:
		demand_for[_artikel] = size * 5
	for _artikel in artikels.manufactured_goods:
		demand_for[_artikel] = size
	for _artikel in artikels.raw_materials:
		demand_for[_artikel] = size
	for _artikel in artikels.spices:
		demand_for[_artikel] = size
	for _artikel in artikels.treasure:
		demand_for[_artikel] = size


func weekly_tick():
	set_demand()
	production()
	consumption()
	set_demand_price()

func consumption():
	eat()
	consume()
	grow_check()

func consume():
	for _artikel in artikels.manufactured_goods:
		increment_cargo(_artikel, -size)
	for _artikel in artikels.raw_materials:
		increment_cargo(_artikel, -size)
	for _artikel in artikels.spices:
		increment_cargo(_artikel, -size)
	for _artikel in artikels.treasure:
		increment_cargo(_artikel, -size)

func eat():
	var food_consumed = {}
	var starving_citizens = 0
	for i in range(size * 5):
		var cheapest_food = [99999, null]
		var food_found = false
		for _artikel in artikels.foods:
			if artikel_price[_artikel] < cheapest_food[0] and get_cargo_quantity(_artikel) > 0:
				food_found = true
				cheapest_food = [artikel_price[_artikel], _artikel]

		if food_found == true:
			if cheapest_food[1] in food_consumed:
				food_consumed[cheapest_food[1]] += 1
			else:
				food_consumed[cheapest_food[1]] = 1
			increment_cargo(cheapest_food[1], -1)
			set_demand_price()
		if food_found == false:
			starving_citizens += 0.5
	starving_citizens = int(round(starving_citizens))
	for each in food_consumed.keys():
		var text = city_name.capitalize() + " consumed " + str(food_consumed[each]) + " " + each + "."
		get_tree().root.get_node("Main/UILayer/MessageLogDisplay").new_message(text)
	if starving_citizens > 0:
		var text = str(starving_citizens) + " citizens went hungry in " + city_name.capitalize()
		get_tree().root.get_node("Main/UILayer/MessageLogDisplay").new_message(text)
		size = max(1, size - starving_citizens)
		population = size * 1000

func grow_check():
	var cheap_food = true
	while cheap_food == true and growth_counter < growth_cap:
		for artikel in artikels.foods:
			cheap_food = false
			if artikel_price[artikel] < 30:
				growth_counter += 1
				cheap_food = true
			if growth_counter == growth_cap:
				continue
	if growth_counter == growth_cap:
		grow()

func grow():
	size += 1
	var text = city_name + " has grown to size " + str(size)
	get_tree().root.get_node("Main/UILayer/MessageLogDisplay").new_message(text)
	population += 1
	growth_counter = 0
	growth_cap = size * size * 10
	resort_neighborhood()
			
func get_price(qartikel):
	return artikel_price[qartikel]

func get_center():
	return Vector2($BBox.position.x, $BBox.position.y + 32)

func set_bounding_box():
	city_tilemap = get_tree().root.get_node("Main/WorldGen/CityMap")
	$BBox.position = city_tilemap.map_to_world(map_tile)
	$SelectionBox.position = $BBox.position



func connect_signals(player_node, info_card):
	self.connect(
		"right_click",
		player_node,
		"_on_City_right_click")
	self.connect(
		"hovered",
		info_card,
		"_on_Entity_hovered")
	self.connect(
		"unhovered",
		info_card,
		"_on_Entity_unhovered"
	)

func _on_BBox_mouse_entered():
	$SelectionBox.visible = true
	$BBox/Label.visible = true
	$BBox/Label/NameLabel.visible = true
	emit_signal("hovered",
		0,
		[city_name,
		 "Joe Schmoe",
		 population,
		 production_last])

func _on_BBox_mouse_exited():
	$SelectionBox.visible = false
	$BBox/Label.visible = false
	$BBox/Label/NameLabel.visible = false
	emit_signal("unhovered")

func _on_BBox_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("right_click"):
		emit_signal("right_click", self)
