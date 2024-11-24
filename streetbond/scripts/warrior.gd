extends CharacterBody3D


const SPEED = 20
const JUMP_VELOCITY = 4.5

var Health = 100
var state = 0
var direction
var target
var enemy

@onready var base_2: Node3D = $"../base2"
@onready var base_1: Node3D = $"../base1"

@export var is_enemy = 0

@onready var health_bar: ProgressBar = $Sprite3D/SubViewport/ProgressBar
@onready var timer: Timer = $Timer

func _ready() -> void:
	if is_enemy == 0:
		target = base_2
	if is_enemy == 1:
		target = base_1

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not is_instance_valid(target):
		if is_enemy == 0:
			target = base_2
		if is_enemy == 1:
			target = base_1
		

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if state == 0 || state == 1:
		direction = (target.position - position).normalized()
		look_at(target.position)
	if state == 2:
		direction = 0
		
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if Health <= 0:
		queue_free()


func _on_view_body_entered(body: Node3D) -> void:
	if (state == 0):
		var pos = (body.position - position).normalized()
		
		if position.distance_to(pos) > 5 && is_enemy == 0 && body.is_enemy == 1:
			target = body
			state = 1
		if position.distance_to(pos) > 5 && is_enemy == 1 && body.is_enemy == 0:
			target = body
			state = 1
	

func take_dmg(dmg):
	#if health_bar.value < dmg:
		#dmg = health_bar.value
	Health -= dmg
	health_bar.value = Health
	

func _on_view_body_exited(body: Node3D) -> void:
	#state = 0
	pass


func _on_hitbox_body_entered(body: Node3D) -> void:
	#body.take_dmg(50)
	enemy = body
	timer.start(1)
	state = 2


func _on_hitbox_body_exited(body: Node3D) -> void:
	enemy = null
	timer.stop()
	state = 0

func _on_timer_timeout() -> void:
	if enemy != null:
		enemy.take_dmg(50)
