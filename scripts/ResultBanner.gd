extends CanvasLayer
@onready var title: Label = $"%Title"

func show_result(text: String) -> void:
    title.text = text
    visible = true
    get_tree().paused = true
    $"%RestartButton".pressed.connect(_on_restart, CONNECT_ONE_SHOT)
    $"%MainButton".pressed.connect(_on_main, CONNECT_ONE_SHOT)

func _on_restart() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()

func _on_main() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
