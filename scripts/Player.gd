extends CharacterBody2D

class_name Player
@export var speed := 200
@export var jump_force := -400
var gravity := 900

var score: int = 0

func _physics_process(delta):

	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()

	if position.y > 600:
		get_tree().change_scene_to_file("res://scenes/LoseScreen.tscn")
