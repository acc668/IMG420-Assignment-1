extends Area2D
@export var message: String = "You Died!"
@onready var sfx: AudioStreamPlayer = $HitSFX

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(b: Node) -> void:
    if not b.is_in_group("player"):
        return
    if sfx and sfx.stream:
        sfx.play()

    # Prefer a player-provided die() hook if available
    if b.has_method("die"):
        b.die(message)
        return

    # Try a ResultBanner overlay if present
    var banner := get_tree().root.find_child("ResultBanner", true, false)
    if banner and banner.has_method("show_result"):
        banner.show_result(message)
        return

    # Fallback: quick restart
    var tree := get_tree()
    if tree:
        tree.reload_current_scene()
