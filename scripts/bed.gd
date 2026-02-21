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
		end_game_check()

func end_game_check():
	var inventory = player_in_range.inventory
	
	# Create a list of keys (item names) where the value is 0
	var missing_items = inventory.keys().filter(func(item): return inventory[item] == 0)
	
	if missing_items.is_empty():
		player_in_range.set_movement_enabled(false)
		await fade_out()
		get_tree().change_scene_to_file("res://scenes/ending.tscn")
		print("You finished the game")
	else:
		# Join the missing items with a comma for a clean message
		var list_string = ", ".join(missing_items)
		print("You are missing: " + list_string)
		
func fade_out(): 
	var fade_ref = get_tree().current_scene.get_node("FadeLayer/FadeRect")
	var tween = create_tween()
	tween.tween_property(fade_ref, "modulate:a", 1.0, 2.5)
	await tween.finished
	
