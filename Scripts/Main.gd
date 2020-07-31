extends Node

func _ready():
	print("starting")
	$UILayer/MainMenu.show()
	get_tree().paused = true


func load_game():
	pass

func new_game():
	$UILayer/MainMenu/MapGenMessage.show()
	$UILayer/MainMenu/MapGenMessage/Label.text = "Generating Map..."
	$WorldGen.gen_new(300, 300)
	$UILayer/MapWidget.setup_references($WorldGen.width, $WorldGen.height)
	$UILayer/MapWidget.redraw_minimaps()
	$Player.randomize_start($Cities)
	$UILayer/MainMenu/MapGenMessage/Label.text = "Generating AI Captains..."
	# $Captains.generate_random_captains($Cities.get_children(), 3)
	$Calendar.set_start_date()
	$Calendar/Timer.start()
	$UILayer/MessageLogDisplay.clear_all()
	$Sounds/Stream/GullsShort.play()


func _on_NewGameButton_pressed():
	get_tree().paused = false
	$UILayer/LoadSplash.show()
	new_game()
	$UILayer/LoadSplash.hide()

func all_music_stop():
	$Sounds/Stream/EgyptGulls.stop()
	$Sounds/Stream/Waves_1.stop()


func _on_MusicTimer_timeout():
	var music = randi()%8+1
	$Sounds/MusicTimer.stop()
	if music == 1 or music == 2:
		$Sounds/Stream/Windy.play()
	elif music == 3 or music == 4:
		$Sounds/Stream/Moontide.play()
	elif music == 5 or music == 6:
		$Sounds/Stream/EgyptGulls.play()
	elif music == 7:
		$Sounds/Stream/Waves_1.play()
	elif music == 8:
		$Sounds/Stream/GullsShort.play()
	elif music == 9:
		$Sounds/Stream/GullsFull.play()
	else:
		$Sounds/MusicTimer.wait_time = rand_range(30, 180)
		$Sounds/MusicTimer.start()

func _on_MusTrack_finished():
	$Sounds/MusicTimer.stop()
	$Sounds/MusicTimer.wait_time = rand_range(30, 180)
	$Sounds/MusicTimer.start()
