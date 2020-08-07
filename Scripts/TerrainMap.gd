extends TileMap

var tools
var worldgen
var biomemap
var biome_map
var heightmap
var vegetationmap
var waterflux_map
var map_width
var map_height
# Some values that produce decent results:
# M = 0.625, H = 0.6
var mountain_cutoff
var hill_cutoff
var river_threshold

var terrain_map = []

var terrain = {
	"mountain": [4, 5, 6, 7],
	"hill": [0, 1, 2, 3]}
var grassland_tiles = [16, 17, 18, 19]

func set_maps(worldgen):
	tools = get_tree().root.get_node("Main/Tools")
	worldgen = worldgen
	map_width = worldgen.width
	map_height = worldgen.height
	biomemap = worldgen.biomemap
	biome_map = get_tree().root.get_node("Main/WorldGen/BiomeMap")
	heightmap = worldgen.heightmap
	vegetationmap = get_tree().root.get_node("Main/WorldGen/VegetationMap")
	waterflux_map = get_tree().root.get_node("Main/WorldGen").waterflux_map
	river_threshold = get_tree().root.get_node("Main/WorldGen").river_threshold
	hill_cutoff = get_tree().root.get_node("Main/WorldGen").hill_cutoff
	mountain_cutoff = get_tree().root.get_node("Main/WorldGen").mountain_cutoff

func init_terrainmap():
	for y in range(map_height):
		var row = []
		for x in range(map_width):
			row.append(-1)
		terrain_map.append(row)

func set_terrain(worldgen):
	set_maps(worldgen)
	init_terrainmap()
	var x = 0
	var y = 0
	for row in heightmap:
		x = 0
		for tile in row:
			var height = heightmap[y][x]
			if height >= hill_cutoff:
				vegetationmap.set_cellv(Vector2(x, y), -1)
				biome_map.set_cellv(Vector2(x, y), tools.r_choice(grassland_tiles))
				
				if height >= mountain_cutoff:
					set_cellv(Vector2(x, y), tools.r_choice(terrain["mountain"]))
					biomemap[y][x] = "mountain"
					x += 1
					continue
				set_cellv(Vector2(x, y), tools.r_choice(terrain["hill"]))
				biomemap[y][x] = "hill"
			x += 1
		y += 1
