extends Node2D

var tools
var artikels
var player
var characters
var disposition
var stats = {}
var portrait_id
var age
var firstname_str
var surname_str
var name_str
var title= " ~ "

var recently_visited = {}

func _ready():
	player = get_tree().root.get_node("Main/Player")
	tools = get_tree().root.get_node("Main/Tools")
	artikels = get_tree().root.get_node("Main/Artikels")
	characters = get_tree().root.get_node("Main/Characters")

func initialize():
	portrait_id = (
		characters.available_portrait_ids[randi() % characters.available_portrait_ids.size()])
	#characters.available_portrait_ids.erase(portrait_id)
	firstname_str = characters.first_names[randi() % characters.first_names.size()]
	surname_str = characters.surnames[randi() % characters.surnames.size()]
	name_str = firstname_str + " " + surname_str
	age = randi()%1 + 50
	randomize_stats()

func randomize_stats():
	stats["Honesty"] = randi()%20+1
	stats["Trust"] = randi()%20+1
	stats["Intelligence"] = randi()%20+1
	stats["Perception"] = randi()%20+1
	stats["Charisma"] = randi()%20+1
	stats["Aggresiveness"] = randi()%20+1
	stats["Leadership"] = randi()%20+1

func get_age():
	return age

func choose_greeting():
	return characters.choose_random_greeting()

func get_insult_response():
	return characters.get_insult_response()

func get_compliment_response():
	return characters.get_compliment_response()

func log_visit(city):
	var prices = {}
	for artikel in artikels.artikel_list:
		prices[artikel] = city.artikel_price[artikel]

	recently_visited[city] = [
		get_tree().root.get_node("Main/Calendar").t_days,
		prices]
