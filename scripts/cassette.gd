extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		print("Cassette collected!")
		body.collect_cassette()
		queue_free()
