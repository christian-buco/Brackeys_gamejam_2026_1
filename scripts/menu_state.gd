extends Control

@onready var menu: VBoxContainer = $CenterContainer/Menu
@onready var panel: Panel = $CenterContainer/Panel

func _ready() -> void:
	menu.visible = true
	panel.visible = false
	$Transition.fade_in()
	$Transition.transitioned.connect(_on_transition_transitioned)

func _on_controls_pressed() -> void:
	menu.visible = false
	panel.visible = true


func _on_play_pressed():
	$Transition.transition()


func _on_transition_transitioned() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


# Called when Controls is pressed
func _on_ControlsButton_pressed():
	print("Show controls menu")
	get_tree().change_scene("res://ControlsState.tscn")

# Called when Credits is pressed
func _on_CreditsButton_pressed():
	print("Show credits")
	get_tree().change_scene("res://CreditsState.tscn")

# Called when Quit is pressed
func _on_QuitButton_pressed():
	get_tree().quit()


func _on_back_pressed() -> void:
	_ready()
