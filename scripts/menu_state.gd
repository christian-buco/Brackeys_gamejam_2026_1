extends Control

@onready var menu: VBoxContainer = $CenterContainer/Menu
@onready var panel: Panel = $CenterContainer/Panel
@onready var play_button: Button = $CenterContainer/Menu/Play
@onready var controls_button: Button = $CenterContainer/Menu/Controls
@onready var credits_button: Button = $CenterContainer/Menu/Credits
@onready var quit_button: Button = $CenterContainer/Menu/Quit
@onready var back_button: Button = $CenterContainer/Panel/Back

const NORMAL_COLOR := Color(0.8, 0.8, 0.8, 1)
const FOCUS_COLOR := Color(1, 1, 1, 1)

var menu_buttons: Array = []

func _ready() -> void:
	menu_buttons = [play_button, controls_button, credits_button, quit_button]
	_setup_button_focus()
	_set_menu_active(true)
	$Transition.fade_in()
	$Transition.transitioned.connect(_on_transition_transitioned)

func _on_controls_pressed() -> void:
	_set_menu_active(false)


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
	_set_menu_active(true)

func _setup_button_focus() -> void:
	for b in menu_buttons:
		b.focus_mode = Control.FOCUS_ALL
		b.add_theme_color_override("font_color", NORMAL_COLOR)
		b.focus_entered.connect(_on_button_focus_entered.bind(b))
		b.focus_exited.connect(_on_button_focus_exited.bind(b))

	back_button.focus_mode = Control.FOCUS_ALL
	back_button.add_theme_color_override("font_color", NORMAL_COLOR)
	back_button.focus_entered.connect(_on_button_focus_entered.bind(back_button))
	back_button.focus_exited.connect(_on_button_focus_exited.bind(back_button))

	# Explicit focus order for WASD navigation
	play_button.focus_neighbor_bottom = controls_button.get_path()
	controls_button.focus_neighbor_top = play_button.get_path()
	controls_button.focus_neighbor_bottom = credits_button.get_path()
	credits_button.focus_neighbor_top = controls_button.get_path()
	credits_button.focus_neighbor_bottom = quit_button.get_path()
	quit_button.focus_neighbor_top = credits_button.get_path()

func _set_menu_active(active: bool) -> void:
	menu.visible = active
	panel.visible = not active
	for b in menu_buttons:
		b.focus_mode = Control.FOCUS_ALL if active else Control.FOCUS_NONE
	back_button.focus_mode = Control.FOCUS_ALL if not active else Control.FOCUS_NONE
	if active:
		play_button.grab_focus()
	else:
		back_button.grab_focus()

func _on_button_focus_entered(button: Button) -> void:
	button.add_theme_color_override("font_color", FOCUS_COLOR)

func _on_button_focus_exited(button: Button) -> void:
	button.add_theme_color_override("font_color", NORMAL_COLOR)
