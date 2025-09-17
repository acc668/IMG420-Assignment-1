# scripts/DialogueBox.gd
extends CanvasLayer

@onready var text: RichTextLabel = $MarginContainer/NinePatchRect/VBoxContainer/Text
@onready var name_label: Label = $MarginContainer/NinePatchRect/VBoxContainer/HBoxContainer/NameLabel
@onready var portrait: TextureRect = $MarginContainer/NinePatchRect/VBoxContainer/HBoxContainer/Portrait
@onready var hint: Label = $MarginContainer/NinePatchRect/VBoxContainer/HBoxContainer2/HintLabel

var _queue: Array = []
var _mgr: Node = null
var _typing: bool = false
var _type_index: int = 0
var _current_full_text: String = ""
var _char_delay: float = 0.02
var _timer: float = 0.0

func open_with_queue(lines: Array, mgr: Node) -> void:
    visible = true
    _queue = lines
    _mgr = mgr
    _show_next()

func close() -> void:
    visible = false
    queue_free()

func _process(delta: float) -> void:
    if not visible:
        return
    if _typing:
        _timer -= delta
        while _timer <= 0.0 and _typing:
            _timer += _char_delay
            _type_index += 1
            if _type_index >= _current_full_text.length():
                _finish_typing()
                break
            text.text = _current_full_text.substr(0, _type_index)

func _unhandled_input(event: InputEvent) -> void:
    if not visible:
        return
    if event.is_action_pressed("interact"):
        if _typing:
            _finish_typing(true) # skip to end
        else:
            _show_next()

func _show_next() -> void:
    if _queue.is_empty():
        if _mgr:
            _mgr.call("_end_dialogue")
        return

    var entry = _queue.pop_front()
    # Normalize entry
    var line_text := ""
    var who := ""
    var face: Texture = null
    _char_delay = 0.02

    if typeof(entry) == TYPE_STRING:
        line_text = entry
    elif typeof(entry) == TYPE_DICTIONARY:
        line_text = str(entry.get("text", ""))
        who = str(entry.get("name", ""))
        face = entry.get("portrait", null)
        var spd = entry.get("speed", null)
        if spd != null
