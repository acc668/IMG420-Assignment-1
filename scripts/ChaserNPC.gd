extends Node2D

@export var mimic_path: NodePath            # assign your FlyingMimic node in the level
@export var lines: Array[String] = [
    "…You kept me waiting.",
    "Run."
]                                          # customize freely
@export var interact_action: String = "interact"

var _player_inside: bool = false
var _line_index: int = -1
var _talking: bool = false

@onready var prompt: Label = $Prompt
@onready var interact_area: Area2D = $InteractArea
var _mimic: Node = null

func _ready() -> void:
    prompt.visible = false
    interact_area.body_entered.connect(_on_area_entered)
    interact_area.body_exited.connect(_on_area_exited)
    if mimic_path != NodePath():
        _mimic = get_node(mimic_path)

func _on_area_entered(b: Node) -> void:
    if b.is_in_group("player"):
        _player_inside = true
        if _mimic and _mimic.has_method("start_chase"):
            # show prompt only if chase hasn't started yet
            prompt.visible = (not _mimic.active)
        else:
            prompt.visible = true

func _on_area_exited(b: Node) -> void:
    if b.is_in_group("player"):
        _player_inside = false
        prompt.visible = false
        if _talking:
            _end_dialogue(false)

func _unhandled_input(event: InputEvent) -> void:
    if not _player_inside or not event.is_action_pressed(interact_action):
        return
    # If chase already active, ignore further talks
    if _mimic and _mimic.has_method("start_chase") and _mimic.active:
        return

    if not _talking:
        _start_dialogue()
    else:
        _advance_dialogue()

func _start_dialogue() -> void:
    _talking = true
    _line_index = -1
    prompt.visible = false
    _advance_dialogue()

func _advance_dialogue() -> void:
    _line_index += 1
    if _line_index >= lines.size():
        _end_dialogue(true)
        return
    _show_line(lines[_line_index])

func _show_line(text: String) -> void:
    # quick & simple—reuse the prompt label as a balloon;
    # you can swap this with your DialogueManager box if you prefer.
    prompt.text = text + "\n[Press E]"
    prompt.visible = true

func _end_dialogue(trigger_chase: bool) -> void:
    _talking = false
    prompt.visible = false
    if trigger_chase and _mimic and _mimic.has_method("start_chase"):
        _mimic.start_chase()
