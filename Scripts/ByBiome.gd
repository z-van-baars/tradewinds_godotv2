extends Node2D
var tools

func _ready():
	tools = get_tree().root.get_node("Main/Tools")


enum biomes {
	ALPINE,
	CONIFER,
	DESERT,
	FOREST,
	GRASSLAND,
	JUNGLE,
	LAKE,
	OCEAN,
	PLAINS,
	SEA,
	SHALLOWS,
	SNOWPACK,
	SNOWY_TUNDRA,
	STEPPE,
	TAIGA,
	TUNDRA}

var biome_production = {
	"alpine": {"Beef": 5, "Timber": 2, "Pelts": 1},
	"conifer": {"Beef": 5, "Timber": 3, "Pelts": 2},
	"desert": {
		"Grain": 5,
		"Gold": 0.1,
		"Gems": 0.5,
		"Silver": 0.75,
		"Incense": 1,
		"Saffron": 0.1,
		"Opium": 1,
		"Saltpeter": 0.15,
		"Silk": 0.5},
	"forest": {"Beef": 5, "Timber": 3, "Pelts": 1},
	"grassland": {
		"Wool": 2,
		"Beef": 2,
		"Leather": 1,
		"Cheese": 2,
		"Butter": 1,
		"Vegetables": 2,
		"Flax": 2},
	"jungle": {
		"Allspice": 1,
		"Cardomom": 0.5,
		"Cinnamon": 0.5,
		"Cloves": 1,
		"Cocoa": 1,
		"Coffee": 1,
		"Cumin": 1,
		"Ginger": 1,
		"Mustard": 1,
		"Nutmeg": 1,
		"Pepper": 1,
		"Turmeric": 1,
		"Vanilla": 0.5,
		"Tea": 1,
		"Tropical Fruit": 3,
		"Sugar": 1},
	"lake": {"Fish": 4},
	"ocean": {"Fish": 3, "Shellfish": 2, "Ivory": 0.5},
	"plains": {
		"Grain": 4,
		"Opium": 1,
		"Wine": 1,
		"Fruit": 1,
		"Hemp": 2,
		"Flax": 3,
		"Olive Oil": 3,
		"Citrus": 2,
		"Cotton": 3},
	"savannah": {
		"Grain": 4,
		"Opium": 1,
		"Fruit": 2,
		"Vegetables": 2,
		"Olive Oil": 1,
		"Citrus": 2,
		"Cotton": 2,
		"Silk": 1,
		"Porcelain": 1},
	"sea": {"Fish": 4, "Shellfish": 3},
	"shallows": {"Fish": 2, "Shellfish": 4, "Pearls": 0.5, "Salt": 0.4},
	"snowpack": {"Ivory": 0.5, "Pelts": 1},
	"snowy tundra": {"Ivory": 1},
	"steppe": {"Olive Oil": 2, "Citrus": 2, "Vegetables": 1, "Incense": 1, "Porcelain": 1, "Silver": 0.5},
	"taiga": {"Timber": 3, "Pelts": 1, "Silver": 0.25},
	"tundra": {"Ivory": 0.5, "Pelts": 1}}
	

func flat_production(biome_str):
	var artikels_produced = {}
	for artikel_str in biome_production[biome_str].keys():
		var q = biome_production[biome_str][artikel_str]
		if q < 1:
			if randi()%100 > q:
				artikels_produced[artikel_str] = 1
		else:
			artikels_produced[artikel_str] = q
	return artikels_produced

func random_artikel(biome_str):
	var potential_artikels = []
	for artikel_str in biome_production[biome_str].keys():
		for n in range(biome_production[biome_str][artikel_str]):
			potential_artikels.append(artikel_str)
	return tools.r_choice(potential_artikels)
