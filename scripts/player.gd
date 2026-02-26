extends CharacterBody2D

@export var speed: float = 75.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D

@export_group("Zoom")
@export var normal_zoom: float = 3.0
@export_range(0.5, 3.0, 0.1) var zoomed_out_zoom: float = 2.0

var is_zoomed_out := false
var is_reading_letter := false
var can_move := true

@export_group("Crush")
@export var crush_grace_time: float = 0.1
var crush_timer: float = 0.0

var shake_strength: float = 0.0

var step_distance: float = 16.0
var distance_moved: float = 0.0
var last_position: Vector2 = Vector2.ZERO
var was_moving: bool = false

@onready var icon: Sprite2D = $Icon
var inventory: Dictionary = {"cassette": 0, "painting": 0, "letter": 0}

@onready var ray_up = $RayUp
@onready var ray_down = $RayDown
@onready var ray_left = $RayLeft
@onready var ray_right = $RayRight

func _ready() -> void:
	camera_2d.zoom = Vector2(normal_zoom, normal_zoom)
	last_position = global_position

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_toggle"):
		toggle_zoom()

func toggle_zoom() -> void:
	if is_reading_letter:
		return
	$Camera2D/zoom_audio.play()
	is_zoomed_out = not is_zoomed_out
	var target := zoomed_out_zoom if is_zoomed_out else normal_zoom
	create_tween().tween_property(camera_2d, "zoom", Vector2(target, target), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	set_movement_enabled(not is_zoomed_out)
	shake_strength = 2.0

func set_movement_enabled(enabled: bool) -> void:
	can_move = enabled
	if not enabled:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	if not can_move:
		move_and_slide()
		check_crush(delta)
		return

	var input := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
	velocity = input * speed
	move_and_slide()
	check_crush(delta)

	# Step dust
	var moving := input != Vector2.ZERO
	if moving:
		if not was_moving:
			emit_dust()
			play_footstep()
			distance_moved = 0
		distance_moved += (global_position - last_position).length()
		if distance_moved >= step_distance:
			distance_moved = 0
			emit_dust()
			play_footstep()
	else:
		distance_moved = 0
	was_moving = moving
	last_position = global_position

	if input != Vector2.ZERO:
		play_walk_animation(input)
	else:
		animated_sprite.play("idle")

func play_footstep():
	if not $footsteps_audio.playing:
		$footsteps_audio.play()

func check_crush(delta):
	var is_currently_crushed := false
	var directions = [
		{ "ray": ray_left,  "dir": Vector2.RIGHT,  "opp": ray_right },
		{ "ray": ray_right, "dir": Vector2.LEFT, "opp": ray_left },
		{ "ray": ray_up,    "dir": Vector2.DOWN,    "opp": ray_down },
		{ "ray": ray_down,  "dir": Vector2.UP,  "opp": ray_up }
	]

	for data in directions:
		var ray = data["ray"]
		var opposite_ray = data["opp"]
		var direction = data["dir"]

		if ray.is_colliding():
			var collider = ray.get_collider()

			if is_moving_wall(collider):
				if collider.move_velocity == direction:
					if opposite_ray.is_colliding():
						if is_static_wall(opposite_ray.get_collider()):
							is_currently_crushed = true
	if is_currently_crushed:
		crush_timer += delta
		if crush_timer >= crush_grace_time:
			die()
	else:
		crush_timer = 0.0

func is_static_wall(collider):
	return collider.is_in_group("static_wall")
func is_moving_wall(collider):
	return collider.is_in_group("moving_wall")
	
func die() -> void:
	$death_audio.play()
	can_move = false
	velocity = Vector2.ZERO
	animated_sprite.scale = Vector2(0.6, 1.2)
	shake_strength = 8.0
	Engine.time_scale = 0.1
	await get_tree().create_timer(0.15).timeout
	Engine.time_scale = 1.0
	
	# fade out
	await fade_out()

	var home = get_tree().current_scene.get_node("respawn_point/Marker2D")
	global_position = home.global_position
	animated_sprite.scale = Vector2.ONE
	
	# reset camera on death
	camera_2d.zoom = Vector2(normal_zoom, normal_zoom)
	is_zoomed_out = false
	
	await fade_in()
	can_move = true
	#get_tree().reload_current_scene()

func fade_out() -> void:
	var fade_rect = get_tree().current_scene.get_node("FadeLayer/FadeRect")
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.4)
	await tween.finished

func fade_in() -> void:
	var fade_rect = get_tree().current_scene.get_node("FadeLayer/FadeRect")
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.4)
	await tween.finished
	
func emit_dust() -> void:
	$CPUParticles2D.position = Vector2(randf_range(-4, 4), randf_range(0, 2))
	$CPUParticles2D.restart()

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, 10 * delta)
		camera_2d.offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
	$PointLight2D.energy = 0.55 + sin(Time.get_ticks_msec() * 0.004) * 0.15

func play_walk_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		animated_sprite.play("walk_right" if dir.x > 0 else "walk_left")
	else:
		animated_sprite.play("walk_down" if dir.y > 0 else "walk_up")

func show_icon(icon_index:int) -> void:
	icon.frame = icon_index
	create_tween().tween_property(icon, "modulate:a", 1.0, 0.4)

func hide_icon() -> void:
	create_tween().tween_property(icon, "modulate:a", 0.0, 0.2)

func collect_item(item_type: String) -> void:
	if inventory.has(item_type):
		inventory[item_type] += 1
