extends CharacterBody2D

@export var speed: float = 300.0
@export var max_health: int = 100
@export var fire_rate: float = 0.3

var current_health: int
var can_shoot: bool = true
var power_up_active: bool = false
var invincible: bool = false
var bullet_scene = preload("res://Bullet.tscn")

signal health_changed(new_health)
signal player_died
signal score_changed(new_score)

var score: int = 0

func _ready():
	current_health = max_health
	health_changed.emit(current_health)

func _physics_process(delta):
	var horizontal_input = Input.get_axis("move_left", "move_right")
	var vertical_input = Input.get_axis("move_up", "move_down")
	
	velocity = Vector2(horizontal_input, vertical_input).normalized() * speed
	
	move_and_slide()
	
	var viewport_size = get_viewport_rect().size

	position.x = clamp(position.x, 32, viewport_size.x - 32)
	position.y = clamp(position.y, 32, viewport_size.y - 32)
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	can_shoot = false
	
	var bullet = bullet_scene.instantiate()

	bullet.position = position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	
	if has_node("ShootSound"):
		$ShootSound.play()
	
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func take_damage(amount: int):
	if invincible:
		return
	
	current_health -= amount
	current_health = max(0, current_health)
	health_changed.emit(current_health)
	invincible = true
	modulate = Color(1, 0.5, 0.5, 0.7)
	await get_tree().create_timer(0.5).timeout
	invincible = false
	modulate = Color(1, 1, 1, 1)
	
	if current_health <= 0:
		die()

func die():
	player_died.emit()
	queue_free()

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health)

func add_score(points: int):
	score += points
	score_changed.emit(score)

func activate_power_up(duration: float):
	power_up_active = true
	fire_rate = 0.1
	speed = 450.0
	modulate = Color(0.5, 1, 1, 1)
	
	await get_tree().create_timer(duration).timeout
	
	power_up_active = false
	fire_rate = 0.3
	speed = 300.0
	modulate = Color(1, 1, 1, 1)