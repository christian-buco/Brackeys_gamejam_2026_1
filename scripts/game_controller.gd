extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("game_controller")


func on_item_collected(item_type:String):
	match item_type:
		"letter":
			show_letter_story()
		"cassette":
			pass
		"painting":
			pass

func show_letter_story():
	$CanvasLayer/LetterPopup.show_story("Where am i?")
