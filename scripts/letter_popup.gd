extends Control

@onready var sprite = $Sprite2D
@onready var label = $Label
@export var zoom_time: float = 0.6
@export var zoom_scale: float = 25.0

var player_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.scale = Vector2.ONE
	hide()

func show_story(text: String):
	label.text = text
	
	player_ref = get_tree().current_scene.get_node("Player")
	player_ref.set_movement_enabled(false)
	player_ref.is_reading_letter = true
	
	sprite.scale = Vector2.ZERO
	show()
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(zoom_scale, zoom_scale), zoom_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(zoom_scale * 0.95, zoom_scale * 0.95), 0.1)

	
func _input(event):
	if visible and event.is_action_pressed("interact"):
		close_letter()
		
		
func close_letter():
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await tween.finished
	
	player_ref.set_movement_enabled(true)
	player_ref.is_reading_letter = false
	hide()
