extends Node2D

@onready var map: TileMapLayer = $Tilemap/Maze
var inventory: Dictionary = {"cassette": 0, "painting": 0, "letter": 0}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("game_controller")
	$CanvasLayer.visible = true
	$CanvasLayer2.visible = true

func on_item_collected(item_type:String):
	match item_type:
		"letter":
			$respawn_point.position.x = 850
			$respawn_point.position.y = 225
			inventory["letter"] = 1
			objective_check_collectible()
			show_letter_story()
		"cassette":
			$respawn_point.position.x = 50
			$respawn_point.position.y = 525
			inventory["cassette"] = 1
			objective_check_collectible()
		"painting":
			$respawn_point.position.x = 450
			$respawn_point.position.y = 50
			inventory["painting"] = 1
			objective_check_collectible()
			var tween = create_tween()
			tween.tween_property(map, "modulate:a", 0.0, 0.3)
			await tween.finished

			# 2. Change the Map
			map.clear()
			# Note: Vector2i.ONE is (1, 1). Use Vector2i.ZERO for the top-left corner (0,0).
			map.set_pattern(Vector2i(0, 0), map.tile_set.get_pattern(1))

			# 3. Fade In (Must create a NEW tween here)
			var tween_in = create_tween()
			tween_in.tween_property(map, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			await tween_in.finished

func objective_check_collectible():
	var hud = $HUD
	var player = $Player
	
	var missing_items = inventory.keys().filter(func(item): return inventory[item] == 0)
	
	if missing_items.is_empty():
		hud.change_objective()
		
	else:
		# Join the missing items with a comma for a clean message
		var list_string = ", ".join(missing_items)
		print("You are missing: " + list_string)

func show_letter_story():
	$CanvasLayer/LetterPopup.show_story("
I’ve rewritten this more times than I can count.
Every version feels too small for everything I left unsaid.

I still think about that day.
You were waiting for an answer or a reason to stay,
and I gave you silence instead.

I told myself I needed time.
But time does not fix what we refuse to face.

[shake]I was scared.[/shake]
I did not know how to hold onto something good without breaking it.

If you ever think about what we were, know that I do too.

I am sorry.
	")
