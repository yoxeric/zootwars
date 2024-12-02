extends CharacterBody3D

@export var sync_position := Vector3.ZERO
@export var sync_rotation := Vector3.ZERO
@export var sync_health := 0
@export var sync_state := 0

@onready var base_1: Node3D = $"../base1"
@onready var base_2: Node3D = $"../base2"
const JUMP_VELOCITY = 4.5


var unit_id = 1
var model
var pfp

var team = 0
# --------------
var health = 2
var damage = 1
var speed = 20
var attack_speed = 1
var price = 4
var hit_range = 20
var view_range = 50
# --------------

var level = 1
var xp = 0
var base_health = health
var atk_nb = 0

#enum State {RUN, CHASE, ATTACK}
#var current_state = State.RUN
var state = 0
var direction
var targets = [ ]
var enemys = [ ]

var mob_model
@onready var hitbox: CollisionShape3D = $hitbox/CollisionShape3D
@onready var viewbox: CollisionShape3D = $view/CollisionShape3D

# ui
var health_bar
@onready var health_team1: ProgressBar = $stats/SubViewport/health
@onready var health_team2: ProgressBar = $stats/SubViewport/health2
@onready var level_counter = $stats/SubViewport/level
@onready var level_bar = $stats/SubViewport/levelbar

# animation
@onready var timer: Timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var particles: GPUParticles3D = $GPUParticles3D

const DMG = preload("res://mat/dmg.tres")
const DGR = preload("res://mat/danger.tres")

func _ready():
	set_physics_process(is_multiplayer_authority())
	
	# Setup synchronizer
	if multiplayer:
		# Update network position when actual position changes
		position = sync_position
		rotation = sync_rotation
		health = sync_health
		state = sync_state
	
	# Your existing _ready code...
	mob_model = get_node("man/Plane")
	mob_model.material_overlay = null
	if team == 1:
		health_bar = health_team1
		health_team2.visible = false
		targets.append(base_2)
	if team == 2:
		health_bar = health_team2
		health_team1.visible = false
		targets.append(base_1)

	mob_model = get_node("man/Plane")
	mob_model.material_overlay = null
	if team == 1:
		health_bar = health_team1
		health_team2.visible = false
		targets.append(base_2)
	if team == 2:
		health_bar = health_team2
		health_team1.visible = false
		targets.append(base_1)
	health_bar.max_value = health
	
	level_counter.text = str(level)
	level_bar.max_value = 2 * level
	level_bar.value = xp
	
	hitbox.shape.radius = hit_range
	viewbox.shape.radius = view_range
	
	print(health)
	print(hit_range)
	print(view_range)
	#set_collision_layer_value(team)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		# Update position for non-authority peers
		position = position.lerp(sync_position, delta * 20)
		rotation = rotation.lerp(sync_rotation, delta * 20)
		return
	#states
	# 1 -> run
	# 2 -> chase
	# 3 -> attack
	if state == 0:
		animation_player.play("unites/walk")
		var trgt = targets[0]
		if is_instance_valid(trgt):
			direction = (trgt.position - position).normalized()
			look_at(trgt.position)
	if state == 1:
		if targets.size() > 1:
			animation_player.play("unites/walk")
			var trgt = targets[1]
			if is_instance_valid(trgt):
				direction = (trgt.position - position).normalized()
				look_at(trgt.position)
		else:
			state = 0
	if state == 2:
		direction = 0
		animation_player.play("unites/attack")
		if enemys.is_empty():
			state = 0
			timer.stop()
		
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

	sync_position = position
	sync_rotation = rotation
	sync_health = health
	sync_state = state
	
	#dead
	#zak
	if health <= 0 || (unit_id == 6 && atk_nb >= 5):
		# weeb
		if (unit_id == 5):
			explode(2)	
			await get_tree().create_timer(1).timeout
		var win = price / 2 if price / 2 > 1 else 1
		if team == 1:
			base_2.money += win
		if team == 2:
			base_1.money += win
		queue_free()

func level_up(xpers):
	xp += xpers
	level_bar.value = xp
	if xp >= level * 2:
		xp = 0
		level += 1
		level_counter.text = str(level)
		level_bar.max_value = 2 * level
		level_bar.value = xp
		
		health_bar.max_value = base_health * level
		health += base_health
		health_bar.value = health

# nta7r
func take_dmg(dmg):
	#zak
	if (unit_id == 6):
		return false
	health -= dmg
	if health_bar.value < dmg:
		dmg = health_bar.value
	health_bar.value = health
	if health > 0:
		return false
	else:
		return true

# attack timer
func _on_timer_timeout() -> void:
	if not enemys.is_empty():
		#zak
		if unit_id == 6:
			explode(damage)
		else:
			var enemy = enemys.front()
			attack(enemy, damage)
		# conman
		if unit_id == 9:
			explode(-1)
	timer.start(attack_speed)
	

func attack(enemy, dmg):
	var enemy_lvl = enemy.level
	var is_killed = enemy.take_dmg(dmg * level)
	atk_nb += 1
	if is_killed:
		level_up(enemy_lvl)
		targets.erase(enemy)
		enemys.erase(enemy)
	await enemy.hit_animation()

func explode(dmg):
	for enemy in enemys:
		attack(enemy, -1)
	$smoke_vfx/smoke_low.emitting = true
	$smoke_vfx/smoke_high.emitting = true
	$smoke_vfx/sparcles.emitting = true
	

func hit_animation():
	#var mat = model.get_surface_material(0)
	#mat.albedo_color = Color(randf(), randf(), randf())
	#model.set_surface_material(0, DMG)
	mob_model.material_overlay = DMG
	await get_tree().create_timer(0.1).timeout
	mob_model.material_overlay = DGR
	await get_tree().create_timer(0.1).timeout
	mob_model.material_overlay = DMG
	mob_model.material_overlay = null
	# particles
	particles.emitting = true

# enemy sighted
func _on_view_body_entered(body: Node3D) -> void:
	if  body.team && team != body.team:
		targets.append(body)
		state = 1
	

# enemy lost
func _on_view_body_exited(body: Node3D) -> void:
	if targets.has(body) && body != base_1 && body != base_2:
		targets.erase(body)

# enemy on range
func _on_hitbox_body_entered(body: Node3D) -> void:
	if (body.team != team):
		enemys.append(body)
		timer.start(attack_speed)
		state = 2

# enemy out of range
func _on_hitbox_body_exited(body: Node3D) -> void:
	if (enemys.has(body)):
		enemys.erase(body)
