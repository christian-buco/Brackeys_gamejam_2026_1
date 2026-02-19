extends CanvasLayer

signal transitioned

func transition() -> void:
	$AnimationPlayer.play("fade_to_black")


func fade_in() -> void:
	$AnimationPlayer.play("fade_to_normal")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		emit_signal("transitioned")
