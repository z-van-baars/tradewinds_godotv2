extends Control

signal fire
var gun_rotation
var target_rotation
var rotation_rate
var reload_time
var ship
var rotating
var reloading
var loaded
var muzzle_pt

func _ready():
	gun_rotation = $SpriteGroup.rect_rotation
	muzzle_pt = rect_position + Vector2(100, 0)
	

func _process(delta):
	set_bars()

func set_bars():
	if rotating == false:
		$RotationBar.hide()
		$ReloadBar.show()
		$ReloadBar.value = ($ReloadTimer.time_left / $ReloadTimer.wait_time)
		return
	$ReloadBar.hide()
	$RotationBar.show()
	$RotationBar.value = ($RotationTimer.time_left / $RotationTimer.wait_time)

func import_gun(gun_type):
	$ReloadTimer.wait_time = 2
	$RotationTimer.wait_time = 5


func load_battle(battle_node):
	connect_signals(battle_node)


func connect_signals(battle_node):
	self.connect(
		"fire",
		battle_node,
		"_on_Gun_fire")


func set_rotation(deg):
	gun_rotation += deg
	$SpriteGroup.rect_rotation += deg


func start_rotation():
	$RotationTimer.start()

func start_reload():
	$ReloadTimer.start()


func _on_ReloadTimer_timeout():
	emit_signal("fire", muzzle_pt)


func _on_RotationTimer_timeout():
	pass # Replace with function body.
