extends TileMap
var tools
var worldgen
var heightmap
var moisturemap

var water_cutoff
var world_width
var world_height
var river_threshold

var layer_step = 0.0001

var waterflux_map
var watersource_map


func set_maps(worldgen):
	tools = get_tree().root.get_node("Main/Tools")
	worldgen = worldgen
	water_cutoff = worldgen.water_cutoff
	world_width = worldgen.width
	world_height = worldgen.height
	heightmap = worldgen.heightmap
	moisturemap = worldgen.moisturemap
	river_threshold = worldgen.river_threshold


func generate_watersheds(worldgen):
	print("Generating Watersheds...")
	set_maps(worldgen)
	var tiles_by_height = sort_tiles_by_height()

	init_water_maps()
	flow_by_layer(tiles_by_height)
	print("Finished Generating Watersheds...")

func set_rivers():
	pass

func sort_tiles_by_height():
	var tiles_by_height = {}
	var x = 0
	var y = 0
	for row in heightmap:
		x = 0
		for tile_height in row:
			x += 1
			if tile_height <= water_cutoff:
				continue
			if tiles_by_height.has(stepify(tile_height, layer_step)):
				tiles_by_height[stepify(tile_height, layer_step)].append(Vector2(x, y))
			else:
				tiles_by_height[stepify(tile_height, layer_step)] = [Vector2(x, y)]
		y += 1
	return tiles_by_height

func init_water_maps():
	waterflux_map = []
	watersource_map = []
	for y in range(world_height):
		var wf_row = []
		var ws_row = []
		for x in range(world_width):
			wf_row.append([0, moisturemap[y][x], 0])
			ws_row.append([[], -1])
		waterflux_map.append(wf_row)
		watersource_map.append(ws_row)


func flow_by_layer(tiles_by_height):
	var sorted_layers = tiles_by_height.keys()
	sorted_layers.sort()
	sorted_layers.invert()
	for layer in sorted_layers:
		var tiles_to_flow = tiles_by_height[layer]
		for tile in tiles_to_flow:
			flow(tile)

func flow(tile):
	var neighbor_tiles = tools.get_neighbor_tiles(tile)


	var tile_height = heightmap[tile.y][tile.x]
	if tile_height <= water_cutoff:
		return
	var flux_data = waterflux_map[tile.y][tile.x]
	var input_water = flux_data[0]
	var rainfall = flux_data[1]
	var water_outflow = flux_data[2]

	var flowable_neighbors = []
	var lowest_neighbor = [9999, Vector2(0, 0)]
	for n_tile in neighbor_tiles:
		var neighbor_height = heightmap[n_tile.y][n_tile.x]
		if neighbor_height < tile_height:
			flowable_neighbors.append(n_tile)
			if neighbor_height < lowest_neighbor[0]:
				lowest_neighbor = [neighbor_height, n_tile]
	if flowable_neighbors.size() == 0:
		waterflux_map[tile.y][tile.x] = [
			input_water,
			rainfall + input_water,
			water_outflow]
		return
	
	water_outflow = rainfall + input_water
	waterflux_map[tile.y][tile.x] = [
		input_water,
		rainfall + input_water,
		water_outflow]

	var flow_tile = lowest_neighbor[1]
	var tile_output = tools.get_position_from_tile(tile, flow_tile)
	var tile_inputs = watersource_map[tile.y][tile.x][0]
	watersource_map[tile.y][tile.x] = [
		tile_inputs,
		tile_output]
	

	add_flux(flow_tile, tile)
	if rainfall + input_water > river_threshold:
		var flow_tile_output = watersource_map[flow_tile.y][flow_tile.x][1]
		var flow_tile_inputs = watersource_map[flow_tile.y][flow_tile.x][0]
		flow_tile_inputs.append(tools.get_position_from_tile(flow_tile, tile))
		watersource_map[flow_tile.y][flow_tile.x] = [
			flow_tile_inputs,
			flow_tile_output]
	return

func add_flux(receiving_tile, input_tile):
	var input_data = waterflux_map[input_tile.y][input_tile.x]
	var flux_to_add = input_data[2]
	var flow_data = waterflux_map[receiving_tile.y][receiving_tile.x]
	
	waterflux_map[receiving_tile.y][receiving_tile.x] = [
		flow_data[0] + flux_to_add,
		flow_data[1],
		flow_data[2]]
		
