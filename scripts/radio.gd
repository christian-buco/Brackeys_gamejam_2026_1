extends Area2D

var player_in_range: Node = null

var blinking := false
var blink_state := false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = body
		start_blinking()
		#player_in_range.show_icon(2)

func _on_body_exited(body):
	if body == player_in_range:
		#player_in_range.hide_icon()
		stop_blinking()
		player_in_range = null

func start_blinking():
	blinking = true
	$BlinkTimer.start()

func stop_blinking():
	blinking = false
	$BlinkTimer.stop()
	$Sprite2D.frame = 0

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		submit_item()

func submit_item():
	if player_in_range.inventory["cassette"] == 1:
		print("You submitted cassette")
		$AudioStreamPlayer2D.play()
	else:
		$error_sfx.play()
		print("You don't have a cassette")


func _on_blink_timer_timeout() -> void:
	if not blinking:
		return
	
	blink_state = !blink_state
	
	if blink_state:
		$Sprite2D.frame = 1
	else:
		$Sprite2D.frame = 0
