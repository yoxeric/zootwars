extends CharacterBody3D


const JUMP_VELOCITY = 4.5

@export var team = 0
@export var health = 4
@export var damage = 2
@export var speed = 20
@export var attack_speed = 2
@export var price = 4
var state = 0
var direction
var targets = [ ]
var enemys = [ ]

@onready var base_1: Node3D = $"../base1"
@onready var base_2: Node3D = $"../base2"

@onready var health_bar: ProgressBar = $Sprite3D/SubViewport/ProgressBar
@onready var timer: Timer = $Timer
@onready var animation_player = $AnimationPlayer

func _ready():
	health_bar.max_value = health
	if team == 1:
		targets.append(base_2)
	if team == 2:
		targets.append(base_1)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#states
	# 1 -> run
	# 2 -> shase
	# 3 -> attack
	if state == 0 || state == 1:
		var trgt = targets.back()
		if is_instance_valid(trgt):
			direction = (trgt.position - position).normalized()
			look_at(trgt.position)
	if state == 2:
		direction = 0
		if enemys.is_empty():
			state = 0
			timer.stop()
		
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	if health <= 0:
		var win = price / 2 if price / 2 > 1 else 1
		if team == 1:
			base_2.money += win
		if team == 2:
			base_1.money += win
		queue_free()

func take_dmg(dmg):
	health -= dmg
	if health_bar.value < dmg:
		dmg = health_bar.value
	health_bar.value = health
	if health >= 0:
		return false
	else:
		return true

func _on_timer_timeout() -> void:
	if not enemys.is_empty():
		var enemy = enemys.back()
		var is_dead = enemy.take_dmg(damage)
		if is_dead:
			targets.erase(enemy)
			enemys.erase(enemy)
	timer.start(attack_speed)
	


func _on_view_body_entered(body: Node3D) -> void:
	if (state == 0):
		#var pos = (body.position - position).normalized()
		#if position.distance_to(pos) > 5 && team != body.team:
		if  body.team && team != body.team:
			targets.append(body)
			state = 1
	

func _on_view_body_exited(body: Node3D) -> void:
	if targets.has(body) && body != base_1 && body != base_2:
		targets.erase(body)


func _on_hitbox_body_entered(body: Node3D) -> void:
	#body.take_dmg(50)
	if (body.team != team):
		enemys.append(body)
		timer.start(attack_speed)
		print("attack")
		state = 2

func _on_hitbox_body_exited(body: Node3D) -> void:
	if (enemys.has(body)):
		enemys.erase(body)
