extends Control

@onready var sprite = $Sprite2D
@onready var label = $Label

@export var zoom_time: float = 0.4
@export var zoom_scale: float = 25.0  # Smaller than letter (feels grounded)
@export var sentence_delay: float = 2.5

var player_ref
var current_sign: Area2D

var sentences: Array = []
var current_sentence := 0
var reading_in_progress := false
var closing_in_progress := false

# Track running tween and timer
var current_text_tween: Tween = null
var current_timer: Timer = null

func _ready():
	sprite.scale = Vector2.ONE
	hide()
	label.modulate.a = 0.0

func show_message(text: String, sign_node: Area2D):
	current_sign = sign_node
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

func show_sentence():
	label.text = sentences[current_sentence]
	
	# fade in text animation
	current_text_tween = create_tween()
	current_text_tween.tween_property(label, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await current_text_tween.finished
	current_text_tween = null
	
	# wait for delay or interact
	current_timer = Timer.new()
	current_timer.wait_time = sentence_delay
	current_timer.one_shot = true
	add_child(current_timer)
	current_timer.start()
	await current_timer.timeout
	current_timer.queue_free()
	current_timer = null
	
	# got to next sentence or finish
	if current_sentence < sentences.size() - 1:
		current_sentence += 1
		await sentence_fade_out()
		show_sentence()
	else:
		reading_in_progress = false

func sentence_fade_out():
	current_text_tween = create_tween()
	current_text_tween.tween_property(label, "modulate:a", 0.0, 0.2)
	await current_text_tween.finished
	current_text_tween = null

func _input(event):
	if closing_in_progress:
		pass
	if not visible:
		return
	if reading_in_progress and event.is_action_pressed("interact"):
		if current_text_tween:
			current_text_tween.kill()
			label.modulate.a = 1.0
			current_text_tween = null
		if current_timer:
			current_timer.stop()
			current_timer.queue_free()
			current_timer = null
		
		if current_sentence < sentences.size() - 1:
			current_sentence += 1
			await sentence_fade_out()
			show_sentence()
		else:
			# Last sentence, close sign
			reading_in_progress = false
			await close_sign()
	elif not reading_in_progress and event.is_action_pressed("interact"):
		await close_sign()

func close_sign():
	closing_in_progress = true
	
	sentence_fade_out()
	
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
	if current_sign:
		current_sign.monitoring = true
		current_sign = null
