extends Area2D

@export_multiline var message: String = \
	"You are not whole yet. \nPieces of you remain in this place."

var player_in_range: Node = null

var blinking := false
var blink_state := false

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = body
		start_blinking()

func _on_body_exited(body):
	if body == player_in_range:
		stop_blinking()
		player_in_range = null

# this 3 function is an indicator that a player can interact with the object
func start_blinking():
	blinking = true
	$BlinkTimer.start()

func stop_blinking():
	blinking = false
	$BlinkTimer.stop()
	$Sprite2D.frame = 0

func _on_blink_timer_timeout() -> void:
	if not blinking:
		return
		
	blink_state = !blink_state
	
	if blink_state:
		$Sprite2D.frame = 2
	else:
		$Sprite2D.frame = 0

func _process(_delta):	
	if Input.is_action_just_pressed("interact"):
		pass
	
	if player_in_range and Input.is_action_just_pressed("interact") and self.monitoring == true:
		print("Interacting with sign")
		self.monitoring = false
		show_sign()

func show_sign():
	var popup = get_tree().current_scene.get_node("Popups/SignPopup")
	popup.show_message(message, self)
