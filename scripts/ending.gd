extends Control
@onready var label: RichTextLabel = $CanvasLayer/label
@export var sentence_delay: float = 2.5
var current_text_tween: Tween = null

var sentences = ["Was I dreaming?", "I thought I was alone in the dark.",
				"Every fragment was mine.", "But...", 
				"The maze remembered.", "And now I do."]
				
var current_sentence = 0
var current_timer: Timer = null


func _ready():
	# Whatever text is already in the label in the editor will type out
	show_ending()

func show_ending():
	label.text = sentences[current_sentence]
	label.visible_characters = 0  # start hidden
	sentence_fade_in()
	
	# Animation
	var tween = create_tween()
	tween.tween_property(label, "visible_characters", label.get_total_character_count(), 1.5)
	await tween.finished
	tween = null
	# Line by line
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
		show_ending()
	else:
		return
	
func sentence_fade_in():
	current_text_tween = create_tween()
	current_text_tween.tween_property(label, "modulate:a", 1.0, 0.4)
	await current_text_tween.finished
	current_text_tween = null

func sentence_fade_out():
	current_text_tween = create_tween()
	current_text_tween.tween_property(label, "modulate:a", 0.0, 0.2)
	await current_text_tween.finished
	current_text_tween = null
