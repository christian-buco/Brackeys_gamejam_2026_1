extends Node2D


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
			pass

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
