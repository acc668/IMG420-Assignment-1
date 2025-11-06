extends Area2D

@export var value: int = 1

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.score += value
		queue_free()
