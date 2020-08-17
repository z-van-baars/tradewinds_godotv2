extends KinematicBody2D

var speed = 10
var direction = Vector2.ZERO

func _ready():
	set_direction()

func _physics_process(delta):
	var movement = speed * direction * delta
	move_and_collide(movement)


func set_direction():
	var rand_up_down = randi()%10 - 5
	direction = Vector2(1, rand_up_down)
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
