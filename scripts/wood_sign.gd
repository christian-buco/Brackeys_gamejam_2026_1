extends Area2D

@export var message: String = "You are not whole yet. \nPieces of you remain in this place."

var player_in_range: Node = null

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = body

func _on_body_exited(body):
	if body == player_in_range:
		player_in_range = null

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		show_sign()

func show_sign():
	var popup = get_tree().current_scene.get_node("CanvasLayer2/SignPopup")
	popup.show_message(message)
