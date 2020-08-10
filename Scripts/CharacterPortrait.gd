extends Control
var characters
var character = null

func _ready():
	characters = get_tree().root.get_node("Main/Characters")

func load_character(ch):
	character = ch
	$PortraitImage.texture = characters.portraits[ch.portrait_id]
	$HoverBox/AgeLabel.text = ("Age " + str(ch.get_age()))
	$HoverBox/NameLabel.text = ch.name_str
	$NameLabel.text = ch.name_str
	$TitleLabel.text = ch.title

func _on_Background_mouse_entered():
	$HoverBox.show()


func _on_Background_mouse_exited():
	$HoverBox.hide()
