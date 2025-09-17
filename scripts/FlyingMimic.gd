extends Node2D
# A flying “shadow” that mimics the player's movement with a time delay.
# It replays the player’s path using recorded samples (position + velocity),
# smoothly steering through them. If it touches (or gets within catch_radius), it reloads the scene.

# ---------------- Tunables ----------------
@export var delay_seconds: float = 0.80          # how far behind the mimic is (record/replay delay)
@export var record_hz: float = 90.0              # how often to sample the player (>= your physics FPS is fine)
@export var base_speed: float = 120.0            # min chase speed when far from target sample
@export var max_speed: float = 520.0             # hard speed cap
@export var accel: float = 2400.0                # steering acceleration toward desired velocity
@export var dash_boost_mult: float = 1.35        # extra speed when the recorded player was dashing/very fast
@export var dash_speed_threshold: float = 360.0  # if recorded sample's |vel| >= this, consider it a "dash"
@export var turn_slowdown: float = 0.20          # 0..1: slow slightly on sharp turns for smoothness
@export var catch_radius: float = 28.0           # distance at which player is considered caught
@export var snap_if_far: bool = true             # rubber-band to avoid getting lost
@export var snap_distance: float = 2200.0
@export var snap_offset: Vector2 = Vector2(-140, 0) # where to snap relative to player when too far

# If your chaser has a sprite you want to face its motion:
@export var rotate_to_motion: bool = true

# -------------- Internals ----------------
var _player: Node = null
var _prev_player_pos: Vector2
var _vel: Vector2 = Vector2.ZERO

# Sample buffer: each item = { "t": float(seconds), "pos": Vector2, "vel": Vector2 }
var _samples: Array = []
var _time_accum: float = 0.0                  # running clock for timestamps
var _record_interval: float = 1.0 / 90.0

var _reacquire_accum: float = 0.0
const _REACQUIRE_EVERY := 0.5

@onready var catch_area: Area2D = $CatchArea
@onready var catch_sfx: AudioStreamPlayer = has_node("CatchSFX") ? $CatchSFX : null
@onready var sprite: Node = has_node("AnimatedSprite2D") ? $AnimatedSprite2D : (has_node("Sprite2D") ? $Sprite2D : null)

func _ready() -> void:
    _record_interval = 1.0 / max(5.0, record_hz)
    _acquire_player()
    if _player:
        _prev_player_pos = _player.global_position
    if catch_area:
        catch_area.body_entered.connect(_on_catch_area_body_entered)

func _physics_process(delta: float) -> void:
    # Keep a local running time (not game time, robust to pause)
    _time_accum += delta

    # Reacquire player sometimes (in case of respawn/reload)
    _reacquire_accum += delta
    if _player == null or not is_instance_valid(_player) or _reacquire_accum >= _REACQUIRE_EVERY:
        _acquire_player()
        _reacquire_accum = 0.0
        if _player == null:
            return

    # --- RECORD: capture player samples at a steady cadence ---
    _maybe_record_player_samples(delta)

    if _samples.is_empty():
        return

    # --- REPLAY: find the sample closest to (now - delay_seconds) ---
    var target_time := _time_accum - delay_seconds
    var idx := _find_sample_index_for_time(target_time)
    if idx < 0:
        # not enough history yet; just drift toward the earliest we have
        idx = 0
    var sample := _samples[idx]
    var sample_pos: Vector2 = sample.pos
    var sample_vel: Vector2 = sample.vel

    # Desired direction/speed toward that recorded point
    var to_target := (sample_pos - global_position)
    var dist := to_target.length()
    var dir := (to_target / max(0.0001, dist))

    # Base speed influenced by how far we are from the target sample
    var target_speed := clamp(base_speed + dist * 1.0, base_speed, max_speed)

    # If the recorded player was “dashing” that frame, let the mimic push a bit harder
    if sample_vel.length() >= dash_speed_threshold:
        target_speed = min(max_speed, target_speed * dash_boost_mult)

    # Slow slightly on very sharp turns to keep motion smooth
    if _vel.length() > 0.1:
        var turn_ratio := clamp(_vel.normalized().angle_to(dir).abs() / PI, 0.0, 1.0)
        target_speed *= clamp(1.0 - (turn_ratio * turn_slowdown), 0.5, 1.0)

    var desired_vel := dir * target_speed

    # Accelerate toward desired velocity
    var dv := desired_vel - _vel
    var step := accel * delta
    if dv.length() > step:
        dv = dv.normalized() * step
    _vel += dv

    # Move
    global_position += _vel * delta

    # Optional orientation
    if rotate_to_motion and sprite and _vel.length() > 0.01:
        rotation = _vel.angle()

    # Catch check by distance (belt & suspenders)
    if is_instance_valid(_player):
        if (global_position - _player.global_position).length() <= catch_radius:
            _caught_player()

    # Rubber-band if absurdly far behind (prevents soft-locks)
    if snap_if_far and is_instance_valid(_player):
        var dp := _player.global_position - global_position
        if dp.length() > snap_distance:
            global_position = _player.global_position + snap_offset
            _vel = Vector2.ZERO

    # Trim old samples we no longer need (keep a bit more than delay)
    _trim_old_samples()

# ---------- Recording / Replay helpers ----------
func _maybe_record_player_samples(delta: float) -> void:
    # record at a stable cadence independent of physics FPS
    # (simple accumulator; for more precision you can loop, but this is enough)
    if _player == null: return
    if _samples.is_empty():
        _push_sample()  # seed
        return

    var last_t: float = _samples.back().t
    if (_time_accum - last_t) >= _record_interval:
        _push_sample()

func _push_sample() -> void:
    var pos := _player.global_position
    var vel := (pos - _prev_player_pos) / max(0.000001, _record_interval)  # estimated player vel since last record
    _prev_player_pos = pos
    _samples.push_back({ "t": _time_accum, "pos": pos, "vel": vel })

func _find_sample_index_for_time(target_time: float) -> int:
    # binary search would be ideal; linear is fine for small buffers
    var n := _samples.size()
    if n == 0: return -1
    # find first sample with t >= target_time
    for i in range(n):
        if _samples[i].t >= target_time:
            return i
    # none newer than target → return newest available
    return n - 1

func _trim_old_samples() -> void:
    # Keep only a small tail of history > delay_seconds (e.g., x1.5 buffer)
    var keep_from := _time_accum - (delay_seconds * 1.6)
    var i := 0
    var n := _samples.size()
    while i < n and _samples[i].t < keep_from:
        i += 1
    if i > 0:
        _samples = _samples.slice(i, n - i)

# ---------- Catch / Utilities ----------
func _on_catch_area_body_entered(b: Node) -> void:
    if b and b.is_in_group("player"):
        _caught_player()

func _caught_player() -> void:
    if catch_sfx: catch_sfx.play()
    var tree := get_tree()
    if tree:
        tree.reload_current_scene()

func _acquire_player() -> void:
    var players := get_tree().get_nodes_in_group("player")
    _player = players[0] if players.size() > 0 else null
    if _player:
        _prev_player_pos = _player.global_position
        # seed a couple samples so we don't wait a full delay to start moving
        _samples.clear()
        _push_sample()
