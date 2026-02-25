extends AnimatableBody2D

@export var move_direction = Vector2.RIGHT  # Direction to move
@export var move_distance = 64.0  # How far to move (in pixels)
@export var move_speed = 50.0  # Speed in pixels/second
@export var pause_time = 1.0  # Seconds to wait at each end
@export var auto_start = true
@export var wait_for_item: String = "letter"

var start_position: Vector2
var target_position: Vector2
var is_moving = false
var move_progress = 0.0
var is_paused = false
var current_direction = 1  # 1 = forward, -1 = backward
var move_velocity: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("moving_wall")
	start_position = global_position
	target_position = start_position + (move_direction.normalized() * move_distance)
	
	if auto_start:
		start_moving()

func _physics_process(delta):
	if move_direction == Vector2.ZERO:
		move_velocity = Vector2.ZERO
		return
		
	if not is_moving:
		move_velocity = Vector2.ZERO
		return
	
	if is_paused:
		move_velocity = Vector2.ZERO
		return
	
	move_velocity = move_direction.normalized() * current_direction
	
	# Move the wall
	move_progress += (move_speed / move_distance) * delta * current_direction
	
	# Check if reached end
	if move_progress >= 1.0:
		move_progress = 1.0
		move_velocity = Vector2.ZERO
		await pause_and_reverse()
	elif move_progress <= 0.0:
		move_progress = 0.0
		move_velocity = Vector2.ZERO
		await pause_and_reverse()
	
	# Update position
	global_position = start_position.lerp(target_position, move_progress)
	
func start_moving():
	is_moving = true

func stop_moving():
	is_moving = false
	move_velocity = Vector2.ZERO

func pause_and_reverse():
	is_paused = true
	await get_tree().create_timer(pause_time).timeout
	current_direction *= -1
	is_paused = false

func on_item_collected(item_type:String):
	if item_type == wait_for_item and not is_moving:
		start_moving()


#func _on_crush_detector_body_entered(body: Node2D) -> void:
	#if body.is_in_group("player"):
		#print("Crush detected and found player")
		#if move_direction != Vector2.ZERO:
			#print("Move direction is not zero")
			#var opposite = -move_direction
			#if body.is_blocked_in_direction(opposite):
				#print("DIE??")
				#body.die()
