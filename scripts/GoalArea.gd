extends Area2D
@export var message: String = "You Escaped!"
@onready var sfx: AudioStreamPlayer = $WinSFX

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(b: Node) -> void:
    if not b.is_in_group("player"):
        return
    if sfx and sfx.stream:
        sfx.play()

    # Prefer a player-provided win() hook if available
    if b.has_method("win"):
        b.win(message)
        return

    # Try a ResultBanner overlay if it exists in the scene
    var banner := get_tree().root.find_child("ResultBanner", true, false)
    if banner and banner.has_method("show_result"):
        banner.show_result(message)
        return

    # Fallback: return to main menu (customize if desired)
    var tree := get_tree()
    if tree:
        tree.change_scene_to_file("res://scenes/MainMenu.tscn")
