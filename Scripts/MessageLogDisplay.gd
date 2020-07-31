extends VBoxContainer

var message_scene = preload("res://Scenes/UI/MessageLabel.tscn")
var logging = false
var message_log = []
var active_messages = []
var max_display = 17

func _process(delta):
	rect_position = Vector2(1350, 340)
	rect_size = Vector2(560, 490)
	if get_children().size() >= max_display:
		for i in range(get_children().size() - max_display):
			get_children()[i].queue_free()

func clear_all():
	var message_log = []
	var active_messages = []
	for each in get_children():
		each.queue_free()

func new_message(message_text):
	if logging == false:
		return
	var new_message_scn = message_scene.instance()
	add_child(new_message_scn)
	new_message_scn.get_node("Label").text = message_text
	if get_children().size() >= max_display:
		for i in range(get_children().size() - max_display):
			get_children()[i].queue_free()

func _on_Message_fade_end(message_node):
	message_node.queue_free()

