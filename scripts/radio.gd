extends Area2D

var player_in_range: Node = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = body

func _on_body_exited(body):
	if body == player_in_range:
		player_in_range = null

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		submit_item()

func submit_item():
	if player_in_range.inventory["cassette"] == 1:
		print("You submitted cassette")
		$AudioStreamPlayer2D.play()
	else:
		print("You don't have a cassette")
