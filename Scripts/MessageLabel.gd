extends Control

signal fade_start
signal fade_end
var fading = false

func connect_signals(message_box_node):
	self.connect("fade_start", message_box_node, "_on_Message_fade_start")
	self.connect("fade_end", message_box_node, "_on_Message_fade_end")



func _on_MessageTimer_timeout():
	$FadeTimer.start()

func _on_FadeTimer_fadeout():
	fading = true

func _process(delta):
	if fading:
		var fade_value = $FadeTimer.wait_time / 2 * 255
		$Label.modulate = Color(255, 255, 255, int(fade_value))
