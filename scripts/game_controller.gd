extends Node2D

@onready var map: TileMapLayer = $Tilemap/Maze

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("game_controller")
	$CanvasLayer.visible = true
	$CanvasLayer2.visible = true

func on_item_collected(item_type:String):
	match item_type:
		"letter":
			
			show_letter_story()
		"cassette":
			pass
		"painting":
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
