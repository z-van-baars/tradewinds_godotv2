extends ColorRect

signal battle_won
signal battle_lost
var status_label
var projectile_scene = preload("res://Scenes/Projectile.tscn")
var ship_scene = preload("res://Scenes/BattleShip.tscn")
var gun_scene = preload("res://Scenes/Gun.tscn")

func _ready():
	status_label = get_tree().root.get_node("Main/UILayer/DateBar/StatusLabel")


func _on_WinButton_pressed():
	$OutcomeMessageTimer.start()
	status_label.text = "you won"
	visible = false
	emit_signal("battle_won")
	get_tree().paused = false


func _on_LoseButton_pressed():
	$OutcomeMessageTimer.start()
	status_label.text = "you lost"
	visible = false
	emit_signal("battle_lost")
	get_tree().paused = false


func _on_FightButton_pressed():
	visible = true


func _on_Gun_fire(muzzle_loc):
	var new_proj = projectile_scene.instance()
	$Projectiles.add_child(new_proj)
	new_proj.rect_position = 
