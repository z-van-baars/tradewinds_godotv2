extends TileMap
var worldgen
var biomemap
var tools

var vegetation_types = {
	"alpine": [12, 13],
	"taiga": [0, 1],
	"conifer": [2, 3],
	"forest": [4, 5, 6],
	"jungle": [8, 9, 10, 11]}

func set_maps(worldgen):
	tools = get_tree().root.get_node("Main/Tools")
	worldgen = worldgen
	biomemap = worldgen.biomemap


func set_vegetation(worldgen):
	set_maps(worldgen)
	var jungle_count = 0
	var y = 0
	for row in biomemap:
		var x = 0
		for str_biome in row:
			if str_biome == "jungle":
				jungle_count += 1
			if str_biome in vegetation_types.keys():
				var tile_id = tools.r_choice(vegetation_types[str_biome])
				set_cell(x, y, tile_id)
			x += 1
		y += 1
	print("New Jungle Count: " + str(jungle_count))
