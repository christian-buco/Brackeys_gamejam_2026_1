extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(true)


func _input(event):
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://scenes/menu_state.tscn")
		
