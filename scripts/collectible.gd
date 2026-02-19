extends Area2D

@onready var sprite: AnimatedSprite2D = $Visual/AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var item_type:String = "cassette"
@export var bob_height: float = 4.0
@export var bob_speed: float = 1.2

@onready var visual = $Visual


func _ready():
	sprite.play(item_type)
	start_bobbing()
	
func start_bobbing():
	var tween = create_tween()
	tween.set_loops()
	
	tween.tween_property(
		visual,
		"position:y",
		visual.position.y - bob_height,
		bob_speed
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(
		visual,
		"position:y",
		visual.position.y,
		bob_speed
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		visual,
		"rotation_degrees",
		5,
		bob_speed
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(
		visual,
		"rotation_degrees",
		-5,
		bob_speed * 2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		visual,
		"rotation_degrees",
		0,
		bob_speed
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
signal collected(item_type)

func _on_body_entered(body):
	if body.name == "Player":
		body.collect_item(item_type)
		
		get_tree().current_scene.on_item_collected(item_type)
		
		sprite.play("collect")
		await sprite.animation_finished
		emit_signal("collected", item_type)
		

		queue_free()
