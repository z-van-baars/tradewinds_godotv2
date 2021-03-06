extends TextureRect

var sounds
var tools
var open_city
var market_menu
var exchange_menu
var portraits
var dragging = false
var drag_offset = Vector2(0, 0)

func _ready():
	clear_all()
	tools = get_tree().root.get_node("Main/Tools")
	sounds = get_tree().root.get_node("Main/Sounds")
	exchange_menu = get_tree().root.get_node("Main/UILayer/ExchangeMenu")
	portraits = [
		load("res://Assets/UI/portraits/city_a.png"),
		load("res://Assets/UI/portraits/city_b.png"),
		load("res://Assets/UI/portraits/city_c.png"),
		load("res://Assets/UI/portraits/city_d.png")]

func _process(delta):
	# Right now it's possible to drag the menu offscreen
	# so that it cannot be closed or exited
	# need to either:
	# 1 - bound dragging to screen size - menu size
	# 2 - remove menus that are offscreen
	# 3 - add manual way to close offscreen menus - keyboard shortcut esc
	if dragging:
		rect_position = get_global_mouse_position() - drag_offset
func clear_all():
	var x = get_viewport().size.x / 2 - rect_size.x / 2
	var y = get_viewport().size.y / 2 - rect_size.y / 2
	rect_position = Vector2(x, y)
	$CityName.text = "N/A"
	
func set_all():
	exchange_menu.load_exchange(self.open_city, self)
	exchange_menu.set_all()
	$CityName.text = str(open_city.name_str)
	$CityPortrait.texture = portraits[open_city.portrait_id]
	$InfoPanel/PopLabel.text = "Population - " + str(open_city.population)
	$InfoPanel/GrowthLabel.text = (
		"Growth Cap - " + str(open_city.growth_counter) + " / " + str(open_city.growth_cap))


func _on_XButton_pressed():
	sounds.get_node("UI/Click_1").play()
	get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").hide()
	get_tree().paused = false
	clear_all()
	hide()
	sounds.get_node("Stream/AtBay").stop()
	sounds.get_node("UI/Close_1").play()
	get_tree().root.get_node("Main/Sounds/MusicTimer").wait_time = rand_range(0.5, 3)
	get_tree().root.get_node("Main/Sounds/MusicTimer").start()
	

func _on_CityMenu_visibility_changed():
	clear_all()
	set_all()

func _on_DragButton_button_down():
	dragging = true
	drag_offset = get_global_mouse_position() - rect_position

func _on_DragButton_button_up():
	dragging = false
	drag_offset = rect_position - get_global_mouse_position()

func _on_MarketButton_pressed():
	sounds.get_node("UI/Click_1").play()
	sounds.get_node("Stream/AtBay").stop()
	hide()

func _on_Dispatcher_open_city_menu(city_to_open):
	get_tree().root.get_node("Main").all_music_stop()
	sounds.get_node("UI/Cabinet_1").play()
	sounds.get_node("Stream/AtBay").play()
	get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel").show()
	get_tree().paused = true
	open_city = city_to_open
	set_all()
	show()
