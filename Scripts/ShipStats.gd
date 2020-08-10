extends Node2D
# Cog
# Starting Ship - All Rounder, Slow, Decent Cargo, no officers

# Caravel
# Early Game All Rounder - Slow, Increased Cargo, More Officers

# Carrack
# Early Game Cargo Ship - Slow, More Cargo, Higher Officer + Crew Requirements

# Galleon
# Early Mid Game All Rounder - Medium Speed, High Cargo Space, High Officer Count
# High Crew Requirements and Upkeep Costs
# Increased Armaments (1 gun deck?)

# Fluyt
# Dedicated Cargo Ship - Medium Speed, Medium Cargo Space, Middling Officer Count
# Moderate Crew Requirements and Low Upkeep
# Poor or no Armaments

# Clipper
# LATE GAME
# Dedicated Cargo Ship - Fast Speed, High Cargo, Middling Officer Count
# Moderate Crew Requirements and Moderate Upkeep
# Poor or no Armamaments

# Schooner
# Mid - Late Game small all purpose Ship
# Moderate Armamaments - Fast, Low Crew

# Gun Brig / Cutter / Schooner
# unknown number - very common
# Very Small Fast Warship
# 4 - 14 guns
# 20 - 90 Men

# Sloop of war
# 76 vessels
# small fast dedicated warship
# 16 guns
# 90 - 125 men

# Corvette
# 40 vessels
# Dedicated Warship - Medium Speed, Low Cargo, Middling Officer Count
# Moderate Crew Requirements, Moderate Upkeep
# 24 guns
# 100 - 150 men

# Frigate
# Dedicated Warship - Medium Speed, Some Cargo, Middling Officer Count
# Medium Crew Requirements, Medium Upkeep
# 100 Vessels
# Upgraded Warship with 2 gun Decks
# 44 guns
# 2 - 300 men

# Ship Of the Line
# 
# Endgame Warship - Medium Speed, Medium Cargo, High Officer Count
# Highest Crew Requirements, Highest Upkeep, Highest Armament
# Different Ratings with Different Gun Counts

# 1st Rate - 3 Gun Decks - 100+ - 800-875 men
# 2nd Rate - 3 Gun Decks - 80-98 - 700-800 men
# 3rd Rate - 2 Gun Decks - 64-80 - 500 - 650 men
# 4th Rate - 2 Gun Decks - 50-60 - 300 - 500 men



var all_hulls = [
	"galleon",
	"cog"
]
var speed = {
	"galleon": 200,
	"cog": 75
}
var cargo_cap = {
	"galleon": 500,
	"cog": 50}


func get_officer_slots(hull_class):
	var officer_types = [
		"Quartermaster",
		"1st Lieutenant",
		"2nd Lieutenant",
		"3rd Lieutenant",
		"Bosun",
		"Surgeon",
		"Navigator",
		"Master Gunner",
		"Carpenter",
		"Engineer"]
	
	var all_hull_slots = [
		"cog",
		"caravel",
		"carrack",
		"galleon",
		"fluyt",
		"clipper",
		"schooner",
		"cutter",
		"sloop",
		"corvette",
		"frigate",
		"ship of the line 1st rate",
		"ship of the line 2nd rate",
		"ship of the line 3rd rate",
		"ship of the line 4th rate"]
	
	var slots_by_class = {}
	for each in all_hull_slots:
		slots_by_class[each] = {}
		for o_type in officer_types:
			slots_by_class[each][o_type] = false
		slots_by_class[each]["Quartermaster"] = true
		slots_by_class[each]["1st Lieutenant"] = true

	var small_ships = all_hull_slots.slice(2, all_hull_slots.size())
	for t_ship in small_ships:
		slots_by_class[t_ship]["Navigator"] = true
	var medium_ships = ["carrack", "galleon", "fluyt", "clipper", "schooner"]
	medium_ships += all_hull_slots.slice(9, all_hull_slots.size())
	for t_ship in medium_ships:
		slots_by_class[t_ship]["2nd Lieutenant"] = true
		slots_by_class[t_ship]["Bosun"] = true
	
	var large_ships = all_hull_slots.slice(10, all_hull_slots.size())
	for t_ship in large_ships:
		for oc in ["Carpenter",
				   "Engineer"]:
			slots_by_class[t_ship][oc] = true
			slots_by_class[t_ship][oc] = true
	
	var gunships = all_hull_slots.slice(8, all_hull_slots.size())
	for t_ship in gunships:
		for oc in ["Surgeon",
				   "Master Gunner"]:
			slots_by_class[t_ship][oc] = true
			slots_by_class[t_ship][oc] = true
		
	return slots_by_class[hull_class]
