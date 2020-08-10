extends Node
var width
var height
var heightmap = []
var tempmap = []
var moisturemap = []
var biomemap = []
var terrain_map = []
var rivermap = []
var waterflux_map = []
var watersource_map = []

var tools
var cities

var water_cutoff = 0.55
var sea_cutoff = 0.50
var ocean_cutoff = 0.45
var river_threshold = 300
var erosion_strength = 0.00005
var hill_cutoff = 0.580
var mountain_cutoff = 0.605
var n_erosion = 30
var noise = OpenSimplexNoise.new()

func _ready():
	tools = get_tree().root.get_node("Main/Tools")
	cities = get_tree().root.get_node("Main/Cities")
	# Configure
	randomize()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8


func gen_new(w=100, h=100, weeks=10):
	width = w
	height = h
	tools.set_map_parameters(width, height)
	
	$BiomeMap.clear()
	$TempMap.clear()
	$MoistureMap.clear()
	print("Generating Heightmap...")
	generate_heightmap()
	print("...Finished Heightmap")
	print("Generating Tempmap...")
	generate_tempmap()
	print("...Finished Tempmap")
	print("Generating Moisturemap...")
	print("...Finished Moisturemap")
	generate_moisturemap()
	$WatershedMap.generate_watersheds(self)
	for i in range(n_erosion):
		waterflux_map = $WatershedMap.waterflux_map
		watersource_map = $WatershedMap.watersource_map
		erode(1)
	$RiverLayer.create_river_nodes()
	# boost_river_moisture($RiverLayer.rivers)
	
	print("Setting Biomes...")
	set_biomes()
	$TempMap.set_temp(self)
	$MoistureMap.set_moisture(self)
	$BiomeMap.set_biome_type(self)
	$VegetationMap.set_vegetation(self)
	$TerrainMap.set_terrain(self)
	terrain_map = $TerrainMap.terrain_map
	# print("Starting A*")
	# $SeaNavMap.initialize(biomemap, $BiomeMap)
	# print("Finished A* junk")
	var map_arr_list = [
		heightmap,
		tempmap,
		moisturemap,
		biomemap]
	cities.set_map_parameters(
		width, height, map_arr_list)
	print("Generating Cities...")
	cities.gen_cities(weeks)
	# $PreviewContainer.set_dims(width, height)
	# $PreviewContainer.heightmap_preview(heightmap)
	get_tree().root.get_node("Main/UILayer/LoadSplash").hide()
	get_tree().root.get_node("Main/UILayer/MessageLogDisplay").logging = true

func get_noise(nx, ny):
	# rescale from -1.0:+1/0 to 0.0:1.0
	# aka normalize
	return noise.get_noise_2d(nx, ny) / 2.0 + 0.5

func generate_heightmap():
	# higher value means more land but also chance of edge touching
	var a = 0.05
	# pushes the edges farther down
	var b = 0.25
	# how quick the elevation falloff is toward the edges
	var c = 10.00
	for y in range(height):
		var row = []
		for x in range(width):
			var nx = (float(x) / float(width)) - 0.5
			var ny = (float(y) / float(height)) - 0.5
			# Manhattan Distance from edges - don't like
			# d = 2 * max(abs(nx), abs(ny))
			# Euclidian Distance from edges
			var d = 2 * sqrt(nx * nx + ny * ny)
			# print("%s, %s", [nx, ny])
			# print(d)
			# crunchify the noise by adding higher frequency noise
			# reduces banding and round edges / softness
			var rand_height_1 = 1.00 * get_noise(96 * nx, 96 * ny)
			rand_height_1 += 0.35 * get_noise(128 * nx, 128 * ny)
			rand_height_1 += 0.25 * get_noise(256 * nx, 256 * ny)
			# normalize the value, previous function produces large values
			var rand_height_2 = rand_height_1 / (1.0 + 0.35 + 0.25)
			# add in the egde disincentive
			var rand_height_edge_biased = rand_height_2 + a - b * pow(d, c)
			var rand_height_final = max(0, rand_height_edge_biased)

			row.append(rand_height_final)
		heightmap.append(row)

func get_temperature(x, y, pole_distances):
	"""modified perlin noise generator
	resulting values are normalized into temp """
	var map_hotness = 80
	# boosts the laminarity of the equator
	# 0 is a loose equator, 1.0 is a solid hot band
	var equator_hotness = 0.5
	# effective range of 0.75 for hot hemispheres to 2.0 for frigid world
	var pole_coldness = 1.25
	var noise_strength = 1.5
	var nx = (float(x) / float(width)) - 0.5
	var ny = (float(y) / float(height)) - 0.5
	var temp1 = (noise_strength * get_noise(32 * nx, 32 * ny))
	var max_dist = sqrt(width * height) / 2
	var dist_mod = (pole_distances[y][x] / max_dist) * 2
	var temp2 = (0.5 +
		dist_mod *
		equator_hotness -
		dist_mod *
		pole_coldness)
	var temp3 = temp2 + temp1
	var temp4 = max(temp3, 0) * map_hotness
	var temp5 = min(temp4, 100)
	if temp5 < 0:
		print(temp5)
	return temp5

func set_pole_distances():
	var npoints = int(sqrt(sqrt(width * height)))
	var slope = Vector2(width / npoints, height / npoints)
	var xx = 0
	var yy = height
	var equator = [Vector2(xx, yy)]
	for e in range(npoints + 2):
		xx += slope[0]
		yy -= slope[1]
		equator.append(Vector2(int(xx), int(yy)))

	var pole_distances = []
	for y in range(height):
		pole_distances.append([])
		for x in range(width):
			# north_pole = utilities.distance(0, 0, x, y)
			# south_pole = utilities.distance(width, height, x, y)
			var eq_distances = []
			for each in equator:
				eq_distances.append(tools.distance(each[0], each[1], x, y))
			# equatorial_distance = min(north_pole, south_pole)
			var eq_distance = tools.min_arr(eq_distances)
			pole_distances[y].append(floor(eq_distance))
	return pole_distances

func generate_tempmap():
	var pole_distances = set_pole_distances()
	for y in range(height):
		var row = []
		for x in range(width):
			var new_temp = get_temperature(x, y, pole_distances)
			row.append(round(new_temp))
		tempmap.append(row)

func generate_moisturemap():
	
	var map_dryness = 0.0
	for y in range(height):
		var row = []
		for x in range(width):
			var nx = float(x) / float(width) - 0.5
			var ny = float(y) / float(height) - 0.5
			var moisture_1 = (0.5 * get_noise(62 * nx, 62 * ny))
			# moisture_1 += 0.35 * get_noise(128 * nx, 128 * ny)
			# moisture_1 += 0.15 * get_noise(256 * nx, 256 * ny)
			# var moisture_2 = moisture_1 / (0.50 + 0.35 + 0.15)
			var moisture_2 = moisture_1 * 2
			moisture_2 = max(0, moisture_2 + map_dryness)
			var moisture_3
			if heightmap[y][x] <= water_cutoff:
				moisture_3 = 100
			else:
				moisture_3 = min(100, moisture_2 * 100 - map_dryness * 100)
			row.append(floor(moisture_3))
		moisturemap.append(row)

func erode(iterations=1):
	print("Eroding...")
	var x = 0
	var y = 0
	for row in waterflux_map:
		x = 0
		for tile in row:
			if heightmap[y][x] <= water_cutoff:
				x += 1
				continue
			var flux = tile[1]
			heightmap[y][x] = max(
				water_cutoff + 0.0001,
				heightmap[y][x] - flux * erosion_strength * iterations)
			x += 1
		y += 1
	print("Finished Eroding")
			

func boost_river_moisture(river_list):
	for river in river_list:
		for point in river:
			
			var map_tile = $BiomeMap.world_to_map(Vector2(int(point.x), int(point.y)))
			var m = moisturemap[map_tile.y][map_tile.x]
			if m < 40:
				moisturemap[map_tile.y][map_tile.x] = 45
			elif m >= 40 and m < 50:
				moisturemap[map_tile.y][map_tile.x] = 55

func set_biomes():
	for y in range(height):
		var row = []
		for x in range(width):
			var str_biome = $BiomeSelector.get_biome(
				tempmap[y][x], moisturemap[y][x])
			if heightmap[y][x] > water_cutoff:
				row.append(str_biome)
			elif water_cutoff >= heightmap[y][x] and heightmap[y][x] > sea_cutoff:
				row.append("shallows")
			elif sea_cutoff >= heightmap[y][x] and heightmap[y][x] > ocean_cutoff:
				row.append("sea")
			elif ocean_cutoff >= heightmap[y][x]:
				row.append("ocean")
		biomemap.append(row)
	print("Set all biomes...")

