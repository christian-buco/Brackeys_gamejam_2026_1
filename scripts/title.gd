extends Control

@onready var transition = $Transition

func _ready() -> void:
	transition.transitioned.connect(_on_transition_finished)
	transition.get_node("ColorRect").color = Color(0, 0, 0, 0)  # start transparent so we see the title


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		transition.transition()
		get_viewport().set_input_as_handled()


func _on_transition_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_state.tscn")
