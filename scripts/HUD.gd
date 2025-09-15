extends CanvasLayer

@export var show_timer: bool   = false
@export var show_stamina: bool = true

@onready var dist_lbl: Label   = $"%DistanceLabel"
@onready var time_lbl: Label   = $"%TimerLabel"
@onready var stam_lbl: Label   = $"%StaminaLabel"

var _player: Node = null
var _mimic: Node  = null

func _ready() -> void:
    time_lbl.visible = show_timer
    stam_lbl.visible = show_stamina
    _find_refs()

func _process(_delta: float) -> void:
    if not is_instance_valid(_player) or not is_instance_valid(_mimic):
        _find_refs()
        return

    # Distance (rounded)
    var d := (_player.global_position - _mimic.global_position).length()
    dist_lbl.text = "Distance: %d" % int(d)

    # Optional timer (example: show seconds since start)
    if show_timer:
        var secs := int(Engine.get_physics_frames() / ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))
        time_lbl.text = "Time: %d" % secs

    # Optional: player stamina if your player script exposes a var (e.g., _climb_stamina / climb_stamina_max)
    if show_stamina and _player and _player.has_variable("_climb_stamina"):
        var cur := int(_player.get("_climb_stamina"))
        var maxv := int(_player.get("climb_stamina_max")) if _player.has_variable("climb_stamina_max") else cur
        stam_lbl.text = "Stamina: %d/%d" % [cur, maxv]

func _find_refs() -> void:
    var ps := get_tree().get_nodes_in_group("player")
    var ms := get_tree().get_nodes_in_group("mimic")
    _player = ps[0] if ps.size() > 0 else null
    _mimic  = ms[0] if ms.size() > 0 else null
