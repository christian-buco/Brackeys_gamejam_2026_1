extends CharacterBody2D

@export var speed: float = 100.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Zoom-out
const MAP_RECT := Rect2(16, 16, 1120, 616)
@export var camera_limit_margin: float = 16.0   
@export var camera_inset: float = 0.0          
@export var normal_zoom: float = 3.0          
@export var zoomed_out_zoom: float = 2.0   

var is_zoomed_out := false
@onready var player_camera: Camera2D = $Camera2D

# Crush mechanic
var overlapping_walls := []
@export var crush_grace_time: float
var crush_timer: float = 0.0
var is_currently_crushed: bool = false

var can_move := true

# screen shake
var shake_strength := 0.0


func _ready() -> void:
	# Use scene zoom or our default
	normal_zoom = player_camera.zoom.x
	player_camera.make_current()

	var main := get_parent()
	var zoom_button: Button = main.get_node_or_null("CanvasLayer/ZoomButton")
	if zoom_button:
		_setup_camera_limits(player_camera)
		zoom_button.pressed.connect(_on_zoom_button_pressed.bind(zoom_button))


func _setup_camera_limits(cam: Camera2D) -> void:
	cam.limit_left = int(MAP_RECT.position.x - camera_limit_margin + camera_inset)
	cam.limit_top = int(MAP_RECT.position.y - camera_limit_margin + camera_inset)
	cam.limit_right = int(MAP_RECT.end.x + camera_limit_margin - camera_inset)
	cam.limit_bottom = int(MAP_RECT.end.y + camera_limit_margin - camera_inset)


func _on_zoom_button_pressed(zoom_button: Button) -> void:
	is_zoomed_out = not is_zoomed_out
	if is_zoomed_out:
		player_camera.zoom = Vector2(zoomed_out_zoom, zoomed_out_zoom)
		zoom_button.text = "Zoom In"
		set_movement_enabled(false)
	else:
		player_camera.zoom = Vector2(normal_zoom, normal_zoom)
		zoom_button.text = "Zoom Out"
		set_movement_enabled(true)


func set_movement_enabled(enabled: bool) -> void:
	can_move = enabled
	if not enabled:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	if not can_move:
		move_and_slide()
		return

	var input_vector := Vector2.ZERO

	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# Prevent diagonal speed boost
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()
	check_crush(delta)
	
	if input_vector != Vector2.ZERO:
		play_walk_animation(input_vector)
	else:
		animated_sprite.play("idle")

func _process(delta) -> void:
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, 10 * delta)
		$Camera2D.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

func play_walk_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animated_sprite.play("walk_right")
		else:
			animated_sprite.play("walk_left")
	else:
		if direction.y > 0:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("walk_up")

func check_crush(delta):

	if overlapping_walls.is_empty():
		crush_timer = 0.0
		return
	
	for wall in overlapping_walls:
		if wall.is_moving and not wall.is_paused:
			crush_timer += delta
			
			if crush_timer >= crush_grace_time:
				die()
			return
	crush_timer = 0.0

func die():
	if not can_move:
		return

	can_move = false
	velocity = Vector2.ZERO

	print("CRUSHED")
	animated_sprite.scale = Vector2(0.6, 1.2)
	shake_strength = 8.0

	# Optional: small freeze effect
	Engine.time_scale = 0.1
	await get_tree().create_timer(0.15).timeout
	Engine.time_scale = 1.0


	get_tree().reload_current_scene()


func _on_crush_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("moving_wall"):
		overlapping_walls.append(body)


func _on_crush_detector_body_exited(body: Node2D) -> void:
	if body in overlapping_walls:
		overlapping_walls.erase(body)
