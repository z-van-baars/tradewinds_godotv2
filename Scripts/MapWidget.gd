extends TextureRect

var map_width
var map_height
var biomemap
var tempmap
var moisturemap
var player


func setup_references(width, height):
	biomemap = get_tree().root.get_node("Main/WorldGen").biomemap
	tempmap = get_tree().root.get_node("Main/WorldGen").tempmap
	moisturemap = get_tree().root.get_node("Main/WorldGen").moisturemap
	map_width = width
	map_height = height
	player = get_tree().root.get_node("Main/Player")

func redraw_minimaps():
	var water_color = Color.darkblue
	var land_color = Color.green
	var water_biomes = get_tree().root.get_node("Main/WorldGen/BiomeSelector").water_biomes

	var x = 0
	var y = 0
	var img = create_map_texture()
	for row in biomemap:
		for tile in row:
			if tile in water_biomes:
				img.set_pixel(x, y, water_color)
			else:
				img.set_pixel(x, y, land_color)
			x += 1
		x = 0
		y += 1
	img.unlock()
	var itex = ImageTexture.new()
	itex.create_from_image(img)
	$LandwaterMinimap.texture = itex
	$BiomeMinimap.texture = itex

	var t_colors = {
		4: Color.blue,
		0: Color.cornflower,
		3: Color.green,
		2: Color.orange,
		1: Color.red}
	
	img = create_map_texture()
	x = 0
	y = 0
	img = create_map_texture()
	var temp_color = 0
	for row in tempmap:
		for tile in row:
			temp_color = t_colors[get_temp_tile(tile)]
			img.set_pixel(x, y, temp_color)
			x += 1
		x = 0
		y += 1
	img.unlock()
	itex = ImageTexture.new()
	itex.create_from_image(img)
	$TempMinimap.texture = itex
	
	var m_colors = {
		0: Color.red,
		1: Color.orange,
		2: Color.green,
		3: Color.cornflower}
	
	img = create_map_texture()
	x = 0
	y = 0
	img = create_map_texture()
	var moisture_color = 0
	for row in moisturemap:
		for tile in row:
			moisture_color = m_colors[get_moisture_tile(tile)]
			if biomemap[y][x] in water_biomes:
				img.set_pixel(x, y, Color.navyblue)
			else:
				img.set_pixel(x, y, moisture_color)
			x += 1
		x = 0
		y += 1
	img.unlock()
	itex = ImageTexture.new()
	itex.create_from_image(img)
	$MoistureMinimap.texture = itex

func get_moisture_tile(m):
	if m < 40:
		return 0
	elif m >= 40 and m < 50:
		return 1
	elif m >= 50 and m < 60:
		return 2
	elif m >= 60:
		return 3

func get_temp_tile(t):
	if t < 20:
		return 4
	elif t >= 20 and t < 40:
		return 0
	elif t >= 40 and t < 60:
		return 3
	elif t >= 60 and t < 85:
		return 2
	else:
		return 1

func create_map_texture():
	var img = Image.new()
	img.create(
		map_width,
		map_height,
		false,
		Image.FORMAT_RGBA8)
	img.lock()
	return img


func _on_LandButton_pressed():
	$LandwaterMinimap.show()
	$MoistureMinimap.hide()
	$TempMinimap.hide()
	$BiomeMinimap.hide()


func _on_MoistureButton_pressed():
	$LandwaterMinimap.hide()
	$MoistureMinimap.show()
	$TempMinimap.hide()
	$BiomeMinimap.hide()


func _on_TempButton_pressed():
	$LandwaterMinimap.hide()
	$MoistureMinimap.hide()
	$TempMinimap.show()
	$BiomeMinimap.hide()


func _on_BiomeButton_pressed():
	$LandwaterMinimap.hide()
	$MoistureMinimap.hide()
	$TempMinimap.hide()
	$BiomeMinimap.show()
