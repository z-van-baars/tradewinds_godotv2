extends TextureRect
var player
var ship
onready var portrait_scene = preload("res://Scenes/UI/CharacterPortrait.tscn")

func set_all(player):
	player = player
	ship = player.get_node("Ship")
	
	$ShipLabel.text = ship.ship_name
	create_officer_portraits()


func create_officer_portraits():
	print("cleaning house")
	for portrait in $PortraitGrid.get_children():
		portrait.queue_free()
	for officer_title in ship.officers.keys():
		print(officer_title)
		print(ship.officers[officer_title])
		var new_officer_portrait = portrait_scene.instance()
		$PortraitGrid.add_child(new_officer_portrait)
		new_officer_portrait.load_character(ship.officers[officer_title])
		
