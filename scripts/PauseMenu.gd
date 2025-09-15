extends CanvasLayer

func _ready() -> void:
    visible = false
    $"%ResumeButton".pressed.connect(_on_resume)
    $"%RestartButton".pressed.connect(_on_restart)
    $"%MainButton".pressed.connect(_on_main)
    $"%QuitButton".pressed.connect(_on_quit)

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("pause"):
        toggle()

func toggle() -> void:
    visible = not visible
    get_tree().paused = visible
    # Optional: trap/untrap input with set_process_unhandled_input

func _on_resume() -> void:
    toggle()

func _on_restart() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()

func _on_main() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_quit() -> void:
    get_tree().quit()
