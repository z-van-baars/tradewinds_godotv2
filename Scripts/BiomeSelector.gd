extends Node2D

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

var water_biomes = [
	"ocean",
	"lake",
	"shallows",
	"sea"
]

var water_indexes = [
	28, 29, 30, 31,
	36, 37, 38, 39,
	40, 41, 42, 43]

var biome_strings = {
	"very cold": {
		"very dry": "tundra",
		"dry": "snowy tundra",
		"wet": "snowpack",
		"very wet": "snowpack"},
	"cold": {
		"very dry": "tundra",
		"dry": "grassland",
		"wet": "taiga",
		"very wet": "alpine"},
	"cool": {
		"very dry": "steppe",
		"dry": "grassland",
		"wet": "grassland",
		"very wet": "conifer"},
	"warm": {
		"very dry": "steppe",
		"dry": "plains",
		"wet": "grassland",
		"very wet": "forest"},
	"hot": {
		"very dry": "desert",
		"dry": "steppe",
		"wet": "plains",
		"very wet": "jungle"}}

func get_temp_string(t):
	"""int -> string descriptor"""
	if t < 20:
		return "very cold"
	elif 20 <= t and t < 40:
		return "cold"
	elif 40 <= t and t < 60:
		return "cool"
	elif 60 <= t and t < 80:
		return "warm"
	elif 80 <= t:
		return "hot"

func get_moisture_string(m):
	"""int -> string descriptor"""
	if m < 40:
		return "very dry"
	elif 40 <= m and m < 50:
		return "dry"
	elif 50 <= m and m < 60:
		return "wet"
	elif 60 <= m:
		return "very wet"

func get_biome(t, m):
	var str_temp = get_temp_string(t)
	var str_moisture = get_moisture_string(m)
	return biome_strings[str_temp][str_moisture]
