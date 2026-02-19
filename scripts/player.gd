extends CharacterBody2D

@export var speed: float = 75.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D

# Zoom 
@export_group("Zoom")
# Zoom in
@export var normal_zoom: float = 3.0
# Zoom out
@export_range(0.5, 3.0, 0.1) var zoomed_out_zoom: float = 2.0

var is_zoomed_out := false
var is_reading_letter := false

# Crush mechanic
var overlapping_walls := []
@export var crush_grace_time: float
var crush_timer: float = 0.0
var is_currently_crushed: bool = false

var can_move := true

# screen shake
var shake_strength := 0.0

# step particles
var step_distance = 64.0
var distance_moved = 0.0
var last_position = Vector2.ZERO
var was_moving := false

# interact icon
@onready var icon = $Icon

func _ready() -> void:
	camera_2d.zoom = Vector2(normal_zoom, normal_zoom)
	last_position = global_position


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_toggle"):
		toggle_zoom()

func toggle_zoom() -> void:
	if is_reading_letter:
		return
	is_zoomed_out = not is_zoomed_out
	
	var target_zoom = zoomed_out_zoom if is_zoomed_out else normal_zoom
	
	var tween = create_tween()
	tween.tween_property(camera_2d, "zoom", Vector2(target_zoom, target_zoom), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
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
		return

	var input_vector := Vector2.ZERO

	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# Prevent diagonal speed boost
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()
	var is_moving_now = input_vector != Vector2.ZERO

	if is_moving_now:
		# --- FIRST STEP LOGIC ---
		# If we weren't moving last frame, but we are now: EMIT!
		if not was_moving:
			emit_dust()
			distance_moved = 0 # Reset so the next puff happens after step_distance
		
		# --- DISTANCE LOGIC ---
		distance_moved += (global_position - last_position).length()
		if distance_moved >= step_distance:
			distance_moved = 0
			emit_dust()
	else:
		distance_moved = 0
	
	# Update these at the end of every frame
	was_moving = is_moving_now
	last_position = global_position
	## track distance moved
	#if input_vector != Vector2.ZERO:
		#
		#distance_moved += (global_position - last_position).length()
		#if distance_moved >= step_distance:
			#distance_moved = 0
			#emit_dust()
	#else:
		#distance_moved = 0
	#last_position = global_position
		
	check_crush(delta)
	
	if input_vector != Vector2.ZERO:
		play_walk_animation(input_vector)
	else:
		animated_sprite.play("idle")

func emit_dust():
	var particles = $CPUParticles2D
	
	# Randomize position slightly so it's not always dead center
	# This simulates left foot / right foot steps
	var pos_offset = Vector2(randf_range(-4, 4), randf_range(0, 2))
	particles.position = pos_offset 
	
	particles.restart() # This triggers the one_shot burst

# light pulse
var pulse_time := 0.0
var pulse_speed := 2.0
var base_energy := 0.5
var pulse_amount := 0.15

func _process(delta) -> void:
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, 10 * delta)
		camera_2d.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	pulse_time += delta * pulse_speed
	
	var pulse = sin(pulse_time) * pulse_amount
	$PointLight2D.energy = base_energy + pulse


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


# Collect Cassette Stuff
var inventory = {
	"cassette": 0,
	"painting": 0,
	"letter": 0
}

var bob_tween: Tween

func show_icon():
	# Kill any existing fade to prevent conflicts
	var fade_tween = create_tween()
	# Fade In
	fade_tween.tween_property(icon, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	
	# Start the bobbing loop
	start_bobbing()

func hide_icon():
	var fade_tween = create_tween()
	# Fade Out
	fade_tween.tween_property(icon, "modulate:a", 0.0, 0.2)
	
	# Stop bobbing when hidden
	stop_bobbing()

func start_bobbing():
	if bob_tween: bob_tween.kill() # Ensure we don't stack tweens
	bob_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	
	# Bobs the texture up and down by 4 pixels
	# We use the current offset as the "base" to keep it relative
	var base_offset = icon.offset.y
	bob_tween.tween_property(icon, "offset:y", base_offset - 4, 0.8)
	bob_tween.tween_property(icon, "offset:y", base_offset, 0.8)

func stop_bobbing():
	if bob_tween:
		bob_tween.kill()


func collect_item(item_type: String):
	if inventory.has(item_type):
		inventory[item_type] += 1
		print("Collected %s!" % [item_type])
	else:
		pass
	
# When player goes near bed
