extends CharacterBody2D

# ===========================
# TUNABLES
# ===========================
@export var run_speed: float        = 220.0
@export var run_accel: float        = 0.20
@export var air_accel: float        = 0.10
@export var friction: float         = 0.10

@export var gravity: float          = 1500.0
@export var max_fall_speed: float   = 900.0
@export var fall_gravity_mul: float = 1.25

@export var jump_speed: float       = 420.0
@export var jump_buffer_time: float = 0.12
@export var coyote_time: float      = 0.12
@export var jump_cut_mul: float     = 0.45

@export var wall_slide_speed: float = 60.0
@export var wall_jump_push: float   = 260.0
@export var wall_jump_boost: float  = 420.0

@export var can_climb: bool         = true
@export var climb_speed: float      = 120.0
@export var climb_stamina_max: float = 100.0
@export var climb_stamina_use_per_sec: float = 25.0
@export var climb_stamina_recover_per_sec: float = 30.0

@export var dash_speed: float       = 520.0
@export var dash_time: float        = 0.18
@export var dash_cooldown: float    = 0.08
@export var air_dashes_max: int     = 1

# Corner correction
@export var corner_nudge_pixels: int = 4
@export var corner_nudge_steps: int  = 4

# === NEW: Ledge climb (mantle) ===
@export var mantle_enabled: bool    = true
@export var mantle_up: float        = 24.0    # how high to climb
@export var mantle_forward: float   = 12.0    # how far forward to move
@export var mantle_time: float      = 0.16    # duration of the hop
@export var mantle_stamina_cost: float = 10.0 # optional stamina cost

# ===========================
# INTERNALS
# ===========================
enum MoveState { IDLE, RUN, JUMP, FALL, WALL, CLIMB, DASH, MANTLE }

var _facing: int = 1
var _coyote: float = 0.0
var _jump_buf: float = 0.0

var _is_dashing: bool = false
var _dash_timer: float = 0.0
var _dash_cd: float = 0.0
var _air_dashes_left: int = 1
var _dash_dir := Vector2.ZERO

var _is_wall_left: bool = false
var _is_wall_right: bool = false
var _is_wall_sliding: bool = false

var _climb_stamina: float = 100.0
var _grab_held: bool = false

var _state: MoveState = MoveState.IDLE

# Mantle state
var _is_mantling: bool = false
var _mantle_t: float = 0.0
var _mantle_start: Vector2
var _mantle_end: Vector2
var _mantle_dir: int = 0  # -1 left, +1 right

@onready var ray_left: RayCast2D     = $WallRayLeft
@onready var ray_right: RayCast2D    = $WallRayRight
@onready var head_left: RayCast2D    = $HeadRayLeft
@onready var head_right: RayCast2D   = $HeadRayRight
@onready var anim: AnimatedSprite2D  = has_node("AnimatedSprite2D") ? $AnimatedSprite2D : null

func _ready() -> void:
    _climb_stamina = climb_stamina_max
    _air_dashes_left = air_dashes_max

func _physics_process(delta: float) -> void:
    # Handle on-going mantle first (overrides physics)
    if _is_mantling:
        _update_mantle(delta)
        _set_state(MoveState.MANTLE)
        _play_anim()
        return

    # --- Timers ---
    if is_on_floor():
        _coyote = coyote_time
        _air_dashes_left = air_dashes_max
        if can_climb:
            _climb_stamina = min(climb_stamina_max, _climb_stamina + climb_stamina_recover_per_sec * delta)
    else:
        _coyote = max(0.0, _coyote - delta)

    _jump_buf = max(0.0, _jump_buf - delta)

    if _dash_timer > 0.0:
        _dash_timer -= delta
        if _dash_timer <= 0.0:
            _is_dashing = false
            _dash_cd = dash_cooldown
    if _dash_cd > 0.0:
        _dash_cd -= delta

    # --- Inputs ---
    var x_in := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
    var y_in := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
    if x_in != 0: _facing = x_in
    if Input.is_action_just_pressed("jump"): _jump_buf = jump_buffer_time
    _grab_held = Input.is_action_pressed("grab") and can_climb

    # --- Wall detection ---
    _is_wall_left = ray_left.is_colliding()
    _is_wall_right = ray_right.is_colliding()
    var on_wall := (not is_on_floor()) and (_is_wall_left or _is_wall_right)

    # --- DASH overrides physics ---
    if _is_dashing:
        velocity = _dash_dir * dash_speed
        _move_and_correct()
        _set_state(MoveState.DASH)
        _play_anim()
        return

    # --- Horizontal ---
    var target_x := float(x_in) * run_speed
    var accel := run_accel if is_on_floor() else air_accel
    velocity.x = lerp(velocity.x, target_x, accel)
    if is_on_floor() and x_in == 0:
        velocity.x = lerp(velocity.x, 0.0, friction)

    # --- Gravity / fall ---
    var g := gravity
    if velocity.y > 0.0:
        g *= fall_gravity_mul
    velocity.y = min(velocity.y + g * delta, max_fall_speed)

    # --- Climb / Wall slide ---
    _is_wall_sliding = false
    if on_wall:
        if _grab_held and _climb_stamina > 0.0:
            var climb_v := 0.0
            if Input.is_action_pressed("move_up"): climb_v = -climb_speed
            elif Input.is_action_pressed("move_down"): climb_v = climb_speed
            velocity.y = climb_v
            velocity.x = 0.0
            _climb_stamina = max(0.0, _climb_stamina - climb_stamina_use_per_sec * delta)
        else:
            var pushing_left := _is_wall_left and x_in < 0
            var pushing_right := _is_wall_right and x_in > 0
            if (pushing_left or pushing_right) and velocity.y > wall_slide_speed:
                velocity.y = wall_slide_speed
                _is_wall_sliding = true

    if can_climb and not _grab_held and not is_on_floor():
        _climb_stamina = min(climb_stamina_max, _climb_stamina + (climb_stamina_recover_per_sec * 0.33) * delta)

    # --- NEW: attempt mantle (Up + Grab on a ledge) ---
    if mantle_enabled and on_wall and _grab_held and Input.is_action_just_pressed("move_up"):
        if _try_start_mantle():
            _set_state(MoveState.MANTLE)
            _play_anim()
            return

    # --- Jumping ---
    if _jump_buf > 0.0 and on_wall:
        _jump_buf = 0.0
        var push_dir := (_is_wall_left) ? 1 : -1
        velocity.x = wall_jump_push * float(push_dir)
        velocity.y = -wall_jump_boost
    elif _jump_buf > 0.0 and _coyote > 0.0:
        velocity.y = -jump_speed
        _jump_buf = 0.0
        _coyote = 0.0

    if Input.is_action_just_released("jump") and velocity.y < 0.0:
        velocity.y *= jump_cut_mul

    # --- Dash (8-dir) ---
    if Input.is_action_just_pressed("dash") and _dash_cd <= 0.0:
        var can_ground_dash := is_on_floor()
        var can_air_dash := (not is_on_floor()) and (_air_dashes_left > 0)
        if can_ground_dash or can_air_dash:
            var dir := Vector2(float(x_in), -float(int(Input.is_action_pressed("move_up"))) + float(int(Input.is_action_pressed("move_down"))))
            if dir == Vector2.ZERO:
                dir = Vector2(float(_facing), 0.0)
            _dash_dir = dir.normalized()
            _is_dashing = true
            _dash_timer = dash_time
            _dash_cd = dash_cooldown
            if not is_on_floor(): _air_dashes_left -= 1
            if is_on_floor() and _dash_dir.y < 0.0:
                velocity.y = -jump_speed * 0.6

    # --- Move + corner correction ---
    var rising_before := velocity.y < 0.0
    _move_and_correct(rising_before)

    # --- State & anim ---
    if _is_dashing:
        _set_state(MoveState.DASH)
    elif on_wall and _grab_held and _climb_stamina > 0.0:
        _set_state(MoveState.CLIMB)
    elif _is_wall_sliding:
        _set_state(MoveState.WALL)
    elif not is_on_floor():
        _set_state(MoveState.JUMP if velocity.y < 0.0 else MoveState.FALL)
    else:
        _set_state(MoveState.RUN if abs(velocity.x) > 10.0 else MoveState.IDLE)

    _play_anim()


# ===========================
# Corner correction
# ===========================
func _corner_correction_try_nudges() -> void:
    if corner_nudge_pixels <= 0 or corner_nudge_steps <= 0: return
    for i in range(1, corner_nudge_steps + 1):
        var off := Vector2(i, 0)
        if not test_move(global_transform, off):
            global_position.x += i
            return
        off = Vector2(-i, 0)
        if not test_move(global_transform, off):
            global_position.x -= i
            return

func _move_and_correct(rising_before: bool = false) -> void:
    move_and_slide()
    if rising_before and is_on_ceiling():
        _corner_correction_try_nudges()

# ===========================
# Mantle (ledge climb)
# ===========================
func _try_start_mantle() -> bool:
    # Decide which side we’re on, and whether there’s a "ledge":
    # Body ray collides but head ray does not.
    var side := 0
    if _is_wall_left and not head_left.is_colliding():
        side = -1
    elif _is_wall_right and not head_right.is_colliding():
        side = 1
    else:
        return false

    # Proposed end position
    var end_off := Vector2(mantle_forward * side, -mantle_up)
    var end_ok := not test_move(global_transform, end_off)
    if not end_ok:
        # Try a couple smaller forward steps if blocked
        for f in [mantle_forward * 0.66, mantle_forward * 0.5, mantle_forward * 0.33]:
            end_off = Vector2(f * side, -mantle_up)
            if not test_move(global_transform, end_off):
                end_ok = true
                break
    if not end_ok:
        return false

    # Optional stamina cost
    if can_climb and mantle_stamina_cost > 0.0:
        if _climb_stamina < mantle_stamina_cost:
            return false
        _climb_stamina = max(0.0, _climb_stamina - mantle_stamina_cost)

    _start_mantle(side, end_off)
    return true

func _start_mantle(side: int, end_off: Vector2) -> void:
    _is_mantling = true
    _mantle_t = 0.0
    _mantle_dir = side
    _mantle_start = global_position
    _mantle_end = _mantle_start + end_off
    velocity = Vector2.ZERO
    _set_state(MoveState.MANTLE)

func _update_mantle(delta: float) -> void:
    _mantle_t += delta / max(0.001, mantle_time)
    var t := clamp(_mantle_t, 0.0, 1.0)
    # Ease slightly for a nice hop
    var ease_t := t * t * (3.0 - 2.0 * t)  # smoothstep
    global_position = _mantle_start.lerp(_mantle_end, ease_t)

    if t >= 1.0:
        _is_mantling = false
        # Landed: snap tiny downwards to ensure we're grounded if we're on a floor
        move_and_slide()
        # Optional: add a tiny forward nudge if stuck inside wall by epsilon
        _set_state(MoveState.IDLE if is_on_floor() else MoveState.FALL)

# ===========================
# State & animation helpers
# ===========================
func _set_state(s: MoveState) -> void:
    _state = s

func _play_anim() -> void:
    if anim == null: return
    anim.flip_h = (_facing < 0)
    match _state:
        MoveState.DASH:
            _play_if_has("dash")
        MoveState.MANTLE, MoveState.CLIMB:
            _play_if_has("climb")  # reuse climb anim for mantle
        MoveState.WALL:
            _play_if_has("wall")
        MoveState.JUMP:
            _play_if_has("jump")
        MoveState.FALL:
            _play_if_has("fall")
        MoveState.RUN:
            _play_if_has("run")
        MoveState.IDLE:
            _play_if_has("idle")

func _play_if_has(name: String) -> void:
    if anim.sprite_frames and anim.sprite_frames.has_animation(name):
        if anim.animation != name:
            anim.play(name)
