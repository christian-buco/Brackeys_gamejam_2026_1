extends Control

@onready var menu: VBoxContainer = $CenterContainer/Menu
@onready var panel: Panel = $CenterContainer/Panel

func _ready() -> void:
	menu.visible = true
	panel.visible = false 
	
func _on_controls_pressed() -> void:
	menu.visible = false
	panel.visible = true


# Called when Play is pressed
func _on_play_pressed():
	# Replace with your state switching logic
	print("Start the game")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# Called when Controls is pressed
func _on_ControlsButton_pressed():
	print("Show controls menu")
	get_tree().change_scene("res://ControlsState.tscn") # or open a popup

# Called when Credits is pressed
func _on_CreditsButton_pressed():
	print("Show credits")
	get_tree().change_scene("res://CreditsState.tscn") # or open a popup

# Called when Quit is pressed
func _on_QuitButton_pressed():
	get_tree().quit()
	


func _on_back_pressed() -> void:
	_ready() 
