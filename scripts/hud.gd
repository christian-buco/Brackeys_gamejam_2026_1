extends CanvasLayer

@export var player_path: NodePath

@onready var cassette_icon: TextureRect = $MarginContainer/HBoxContainer/Cassette
@onready var painting_icon: TextureRect = $MarginContainer/HBoxContainer/Painting
@onready var letter_icon: TextureRect = $MarginContainer/HBoxContainer/Letter

@onready var pause_overlay: Control = $PauseOverlay
@onready var pause_panel: PanelContainer = $PauseOverlay/CenterContainer/PanelContainer
@onready var pause_cassette_icon: TextureRect = $PauseOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ItemsIcons/PauseCassette
@onready var pause_painting_icon: TextureRect = $PauseOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ItemsIcons/PausePainting
@onready var pause_letter_icon: TextureRect = $PauseOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ItemsIcons/PauseLetter

var player: Node = null
var overlay_tween: Tween = null

const ITEM_OWNED_COLOR := Color(1, 1, 1, 1)
const ITEM_MISSING_COLOR := Color(1, 1, 1, 0.35)

func _ready() -> void:
	if player_path != NodePath():
		player = get_node_or_null(player_path)
	if player == null:
		player = get_tree().current_scene.get_node_or_null("Player")
	_update_icons()
	self.visible = true 
	pause_overlay.visible = false  

func _process(_delta: float) -> void:
	_update_icons()
	if pause_overlay.visible:
		_update_pause_items()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_toggle"):
		_toggle_pause()
		get_viewport().set_input_as_handled()
		return

func _update_icons() -> void:
	if player == null:
		return
	if not ("inventory" in player):
		return
	var inv: Dictionary = player.inventory
	cassette_icon.visible = inv.get("cassette", 0) > 0
	painting_icon.visible = inv.get("painting", 0) > 0
	letter_icon.visible = inv.get("letter", 0) > 0

func _toggle_pause() -> void:
	if pause_overlay.visible:
		_close_pause()
	else:
		_open_pause()

func _open_pause() -> void:
	pause_overlay.visible = true
	_set_player_movement(false)
	_update_pause_items()

	_kill_overlay_tween()
	pause_panel.scale = Vector2(0.9, 0.9)
	pause_panel.modulate.a = 0.0
	overlay_tween = create_tween()
	overlay_tween.tween_property(pause_panel, "scale", Vector2(1, 1), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	overlay_tween.parallel().tween_property(pause_panel, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _close_pause() -> void:
	_set_player_movement(true)
	_kill_overlay_tween()
	overlay_tween = create_tween()
	overlay_tween.tween_property(pause_panel, "modulate:a", 0.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	overlay_tween.parallel().tween_property(pause_panel, "scale", Vector2(0.92, 0.92), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await overlay_tween.finished
	pause_overlay.visible = false

func _set_player_movement(enabled: bool) -> void:
	if player == null:
		return
	if player.has_method("set_movement_enabled"):
		player.set_movement_enabled(enabled)

func _update_pause_items() -> void:
	if player == null:
		return
	if not ("inventory" in player):
		return
	var inv: Dictionary = player.inventory
	var has_cassette: bool = inv.get("cassette", 0) > 0
	var has_painting: bool = inv.get("painting", 0) > 0
	var has_letter: bool = inv.get("letter", 0) > 0

	var cassette_color := ITEM_OWNED_COLOR if has_cassette else ITEM_MISSING_COLOR
	var painting_color := ITEM_OWNED_COLOR if has_painting else ITEM_MISSING_COLOR
	var letter_color := ITEM_OWNED_COLOR if has_letter else ITEM_MISSING_COLOR

	pause_cassette_icon.modulate = cassette_color
	pause_painting_icon.modulate = painting_color
	pause_letter_icon.modulate = letter_color

func _kill_overlay_tween() -> void:
	if overlay_tween != null and overlay_tween.is_running():
		overlay_tween.kill()
