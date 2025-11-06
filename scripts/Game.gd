extends Node2D

@onready var player: Player = $Player
@onready var score_label: Label = $CanvasLayer/ScoreLabel

func _ready() -> void:
	player.score = 0
	update_hud()

	$Door.connect("body_entered", Callable(self, "_on_door_entered"))

func _process(_delta: float) -> void:
	update_hud()

func update_hud() -> void:
	score_label.text = "Score: " + str(player.score)

func _on_door_entered(body: Node) -> void:
	if body is CharacterBody2D:

		if player.score >= 1:
			get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")
		else:
			# optionally show a message — keep minimal: do nothing
			pass
