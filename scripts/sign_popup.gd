extends Control

@onready var sprite = $Sprite2D
@onready var label = $Label

@export var zoom_time: float = 0.4
@export var zoom_scale: float = 25.0  # Smaller than letter (feels grounded)

var player_ref

func _ready():
	sprite.scale = Vector2.ONE
	hide()

var sentences: Array = []
var current_sentence := 0
var reading_in_progress := false
var closing_in_progress := false
@export var sentence_delay: float = 2.5


func show_message(text: String):
	if reading_in_progress:
		return
	reading_in_progress = true
	player_ref = get_tree().current_scene.get_node("Player")
	player_ref.set_movement_enabled(false)
	player_ref.is_reading_letter = true
	
	sentences = text.split(". ")
	current_sentence = 0
	
	sprite.scale = Vector2.ZERO
	# hide text
	label.modulate.a = 0.0
	label.text = ""
	show()
	
	# sign animation popup
	var tween = create_tween()
	tween.tween_property(sprite, "scale",
		Vector2(zoom_scale, zoom_scale),
		zoom_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	 
	show_sentence()
	# fade in text animation
	var text_tween = create_tween()
	text_tween.tween_property(label, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	

func show_sentence():
	label.text = sentences[current_sentence]
	
	# fade in text animation
	var text_tween = create_tween()
	text_tween.tween_property(label, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await text_tween.finished
	await get_tree().create_timer(sentence_delay).timeout
	
	if current_sentence < sentences.size() - 1:
		current_sentence += 1
		var fade_out = create_tween()
		fade_out.tween_property(label, "modulate:a", 0.0, 0.4)
		await fade_out.finished
		await show_sentence()
	else:
		reading_in_progress = false

func _input(event):
	if reading_in_progress or closing_in_progress:
		return
	if visible and event.is_action_pressed("interact"):
		close_sign()

func close_sign():
	closing_in_progress = true
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale",
		Vector2.ZERO,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await tween.finished
	
	player_ref.set_movement_enabled(true)
	player_ref.is_reading_letter = false
	hide()
	closing_in_progress = false
