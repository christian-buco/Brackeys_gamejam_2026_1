extends Control

@onready var sprite = $Sprite2D
@onready var label = $Label
@export var zoom_time: float = 0.6
@export var zoom_scale: float = 25.0

# Added variables for the shake burst
@export var max_shake: float = 10.0
var current_shake: float = 0.0
var original_label_pos: Vector2
var player_ref

func _ready() -> void:
	original_label_pos = label.position
	sprite.scale = Vector2.ONE
	label.modulate.a = 0
	hide()

func _process(_delta: float) -> void:
	# Only shake if there is intensity
	if current_shake > 0:
		label.position = original_label_pos + Vector2(
			randf_range(-current_shake, current_shake),
			randf_range(-current_shake, current_shake)
		)
	else:
		label.position = original_label_pos

func show_story(text: String):
	$AudioStreamPlayer2D.play()
	label.text = text
	label.modulate.a = 0
	
	player_ref = get_tree().current_scene.get_node("Player")
	player_ref.set_movement_enabled(false)
	player_ref.is_reading_letter = true
	
	sprite.scale = Vector2.ZERO
	show()
	
	var tween = create_tween().set_parallel(true)
	
	# 1. Zoom and Fade
	tween.tween_property(sprite, "scale", Vector2(zoom_scale, zoom_scale), zoom_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 1.0, zoom_time)
	
	# 2. The Shake "Burst"
	# Start with high intensity and fade it to 0 over a short duration
	current_shake = max_shake
	var shake_tween = create_tween()
	shake_tween.tween_property(self, "current_shake", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	label.visible_ratio = 0
	tween.tween_property(label, "visible_ratio", 1.0, 15.0) 
func _input(event):
	if visible and event.is_action_pressed("interact"):
		close_letter()

func close_letter():
	current_shake = 0 # Ensure shake is off
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(label, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	player_ref.set_movement_enabled(true)
	player_ref.is_reading_letter = false
	hide()
