extends Control

@onready var menu: VBoxContainer = $NotDark/Menu
@onready var panel: Panel = $NotDark/CenterContainer/ControlPanel
@onready var panel_label: Label = $NotDark/CenterContainer/ControlPanel/Controls
@onready var credits_panel: Panel = $NotDark/CenterContainer/CreditsPanel
@onready var play_button: Button = $NotDark/Menu/Play
@onready var controls_button: Button = $NotDark/Menu/Controls
@onready var credits_button: Button = $NotDark/Menu/Credits
@onready var quit_button: Button = $NotDark/Menu/Quit
@onready var back_button: Button = $NotDark/CenterContainer/ControlPanel/Back
@onready var sfx_select: AudioStreamPlayer = $SfxSelect
const NORMAL_COLOR := Color(0.8, 0.8, 0.8, 1)
const FOCUS_COLOR := Color(1, 1, 1, 1)

var menu_buttons: Array = []
var _suppress_focus_sfx := true

# DVD-style floaters (bounce + wobble)
const DVD_FLOAT_SPEED := 60.0
const DVD_PADDING := 10.0
const DVD_WOBBLE_DEGREES := 6.0
const DVD_WOBBLE_SPEED := 1.5
var _floaters: Array[Dictionary] = []
var _viewport_size := Vector2.ZERO

func _ready() -> void:
	menu_buttons = [play_button, controls_button, credits_button, quit_button]
	_setup_button_focus()
	_set_menu_active(true)
	credits_panel.visible = false
	$Transition.fade_in()
	$Transition.transitioned.connect(_on_transition_transitioned)
	quit_button.pressed.connect(_on_quit_pressed)
	_setup_dvd_floaters()
	await get_tree().process_frame
	_suppress_focus_sfx = false

func _on_controls_pressed() -> void:
	panel_label.text = "WASD to move"
	_set_menu_active(false)


func _on_play_pressed():
	$Transition.transition()


func _on_transition_transitioned() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_back_pressed() -> void:
	_set_menu_active(true)

func _setup_button_focus() -> void:
	for b in menu_buttons:
		b.focus_mode = Control.FOCUS_ALL
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_theme_color_override("font_color", NORMAL_COLOR)
		b.focus_entered.connect(_on_button_focus_entered.bind(b))
		b.focus_exited.connect(_on_button_focus_exited.bind(b))

	back_button.focus_mode = Control.FOCUS_ALL
	back_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_button.add_theme_color_override("font_color", NORMAL_COLOR)
	back_button.focus_entered.connect(_on_button_focus_entered.bind(back_button))
	back_button.focus_exited.connect(_on_button_focus_exited.bind(back_button))

	# Explicit focus order for WASD navigation
	play_button.focus_neighbor_bottom = controls_button.get_path()
	play_button.focus_neighbor_top = quit_button.get_path()
	controls_button.focus_neighbor_top = play_button.get_path()
	controls_button.focus_neighbor_bottom = credits_button.get_path()
	credits_button.focus_neighbor_top = controls_button.get_path()
	credits_button.focus_neighbor_bottom = quit_button.get_path()
	quit_button.focus_neighbor_top = credits_button.get_path()
	quit_button.focus_neighbor_bottom = play_button.get_path()

func _set_menu_active(active: bool) -> void:
	menu.visible = active
	panel.visible = not active
	credits_panel.visible = false
	for b in menu_buttons:
		b.focus_mode = Control.FOCUS_ALL if active else Control.FOCUS_NONE
	back_button.focus_mode = Control.FOCUS_ALL if not active else Control.FOCUS_NONE
	if active:
		play_button.grab_focus()
	else:
		back_button.grab_focus()

func _on_button_focus_entered(button: Button) -> void:
	button.add_theme_color_override("font_color", FOCUS_COLOR)
	if sfx_select and not _suppress_focus_sfx:
		sfx_select.play()

func _on_button_focus_exited(button: Button) -> void:
	button.add_theme_color_override("font_color", NORMAL_COLOR)


func _on_credits_pressed() -> void:
	panel_label.text = "Credits: Beikon, rezmayyy\n" #Hard coded idc
	_set_menu_active(false)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _setup_dvd_floaters() -> void:
	_viewport_size = get_viewport().get_visible_rect().size
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	randomize()
	for node_path in ["Cassette", "Letter", "Painting", "CanvasModulate/RandomLight"]:
		var node := get_node_or_null(node_path)
		if node == null or not (node is Node2D):
			continue
		var n := node as Node2D
		var mover := n.get_node_or_null("DVDMover")
		if mover:
			mover.queue_free()
		_floaters.append({
			"target": n,
			"velocity": _dvd_random_velocity(DVD_FLOAT_SPEED),
			"base_rotation": n.rotation,
			"wobble_time": 0.0
		})

func _on_viewport_size_changed() -> void:
	_viewport_size = get_viewport().get_visible_rect().size

func _process(delta: float) -> void:
	for data in _floaters:
		var target_node: Node2D = data.target
		if is_instance_valid(target_node):
			_dvd_update_floater(data, delta)

func _dvd_update_floater(data: Dictionary, delta: float) -> void:
	var target_node: Node2D = data.target
	var half_size := _dvd_floater_half_size(target_node)
	var min_x := half_size.x + DVD_PADDING
	var max_x := _viewport_size.x - half_size.x - DVD_PADDING
	var min_y := half_size.y + DVD_PADDING
	var max_y := _viewport_size.y - half_size.y - DVD_PADDING
	var vel: Vector2 = data.velocity
	var pos := target_node.position + vel * delta
	if pos.x < min_x:
		pos.x = min_x
		vel.x = absf(vel.x)
	elif pos.x > max_x:
		pos.x = max_x
		vel.x = -absf(vel.x)
	if pos.y < min_y:
		pos.y = min_y
		vel.y = absf(vel.y)
	elif pos.y > max_y:
		pos.y = max_y
		vel.y = -absf(vel.y)
	data.velocity = vel
	target_node.position = pos
	data.wobble_time += delta * DVD_WOBBLE_SPEED
	target_node.rotation = data.base_rotation + deg_to_rad(DVD_WOBBLE_DEGREES) * sin(data.wobble_time)

func _dvd_floater_half_size(target_node: Node2D) -> Vector2:
	if target_node is Sprite2D:
		var s := target_node as Sprite2D
		if s.texture != null:
			return (s.texture.get_size() * s.scale) * 0.5
	if target_node is Light2D:
		var l := target_node as Light2D
		if l.texture != null:
			return (l.texture.get_size() * l.scale) * 0.5
	return Vector2(16, 16)

func _dvd_random_velocity(speed: float) -> Vector2:
	var dir := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	if dir.length() < 0.2:
		dir = Vector2(1, 0)
	return dir.normalized() * speed
