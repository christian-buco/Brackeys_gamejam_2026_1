extends Node2D

# Map bounds 
const MAP_RECT := Rect2(16, 16, 1120, 616)

## Zoom level when viewing the full map.
@export var map_view_zoom: float = 0.99

@onready var player: CharacterBody2D = $Player
@onready var player_camera: Camera2D = $Player/Camera2D
@onready var map_camera: Camera2D = $MapOverviewCamera
@onready var zoom_button: Button = $CanvasLayer/ZoomButton

var is_zoomed_out := false


func _ready() -> void:
	zoom_button.pressed.connect(_on_zoom_button_pressed)
	_setup_map_camera()
	player_camera.make_current()  # Start zoomed in (following player)


func _setup_map_camera() -> void:
	# Position camera at map center
	map_camera.position = MAP_RECT.get_center()
	map_camera.position_smoothing_enabled = true

	map_camera.zoom = Vector2(map_view_zoom, map_view_zoom)


func _on_zoom_button_pressed() -> void:
	is_zoomed_out = not is_zoomed_out

	if is_zoomed_out:
		map_camera.make_current()
		zoom_button.text = "Zoom In"
		player.set_movement_enabled(false)
	else:
		player_camera.make_current()
		zoom_button.text = "Zoom Out"
		player.set_movement_enabled(true)
