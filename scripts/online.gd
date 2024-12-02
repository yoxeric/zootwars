extends Node3D

var WIN = preload("res://scenes/win.tscn").instantiate()

@export var base_unite = preload("res://scenes/mob.tscn")
@export var base_profile = preload("res://scenes/ui/unit_profile.tscn")

#  ---------- characters ---------- 3d - pic
# - price - hp - atk - spd - atk spd - atk_rng - view_rng -
var mobs = [Mob.new(preload("res://assets/characters/gaiman.blend"), preload("res://assets/characters/gaiman.png"),
2, 2, 1, 25, 1, 10, 50),
Mob.new(preload("res://assets/characters/yungin.blend"), preload("res://assets/characters/yungin.png"),
3, 1, 1, 30, 0.8, 40, 50),
Mob.new(preload("res://assets/characters/grini.blend"),  preload("res://assets/characters/grini.png"),
6, 5, 2, 20, 1.2, 10, 50),
Mob.new(preload("res://assets/characters/zootman.blend"), preload("res://assets/characters/zootman.png"),
5, 1, 2, 70, 0.9, 10, 50),
Mob.new(preload("res://assets/characters/weeb.blend"), preload("res://assets/characters/weeb.png"),
8, 2, 5, 30, 1, 15, 50),
Mob.new(preload("res://assets/characters/zak.blend"), preload("res://assets/characters/zak.png"),
7, 100, 1, 25, 1, 30, 50),
Mob.new(preload("res://assets/characters/sayad.blend"), preload("res://assets/characters/sayad.png"),
8, 2, 2, 20, 1, 70, 100),
Mob.new(preload("res://assets/characters/nsab.blend"), preload("res://assets/characters/nsab.png"),
20, 2, 2, 25, 1, 15, 50),
Mob.new(preload("res://assets/characters/conman.blend"), preload("res://assets/characters/conman.png"),
8, 4, 4, 20, 1, 10, 50)]


@onready var base1: Node3D = $base1
@onready var base2: Node3D = $base2

@onready var plyr: CharacterBody3D = $plyr

@onready var profile_holder : HBoxContainer = $ui/unites
@onready var selection = $ui/selection

@onready var money1 = $ui/team1/money/money_txt
@onready var money2 = $ui/team2/money/money_txt

@onready var hp1 = $ui/team1/hp/hp_txt
@onready var hp2 = $ui/team2/hp/hp_txt

var unit_profiles = [ ]
@export var profile_size = 100
var selected_unite = 1
var player_id = 1

@export var spawn_shift = 58
@export var spawn_size = 400

@export var sync_interval: float = 1.0  # Sync every second
var sync_timer: float = 0.0

@onready var spawner = $MultiplayerSpawner

func _ready() -> void:
	print("Game Started. Initial player_id:", player_id)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Create and setup spawner if it doesn't exist
	if !spawner:
		spawner = MultiplayerSpawner.new()
		add_child(spawner)
	
	spawner.spawn_path = "."
	spawner.add_spawnable_scene(base_unite.resource_path)
	
	# Set player_id based on network role immediately
	if multiplayer.multiplayer_peer != null:
		if multiplayer.is_server():
			player_id = 1
		else:
			player_id = 2
	
	print("My unique ID:", multiplayer.get_unique_id())
	print("Is Server:", multiplayer.is_server())
	print("My player_id:", player_id)
	
	var i = 1
	for x in mobs:
		add_unit_profile(i)
		i += 1

func _on_peer_connected(id):
	print("Peer Connected with ID:", id)
	print("My unique ID:", multiplayer.get_unique_id())
	print("Is Server:", multiplayer.is_server())
	
	# Set correct player_id based on role
	if multiplayer.is_server():
		player_id = 1
		sync_game_state.rpc(base1.money, base1.health, base2.money, base2.health)
	else:
		player_id = 2
		# Flip camera for player 2
		if $Camera3D:
			print("Flipping camera for player 2")
			$Camera3D.rotation_degrees.y = 180
			$Camera3D.position.x *= -1

	print("Final player_id:", player_id)

func _process(delta: float) -> void:
	# Update UI based on player's team
	if player_id == 1:
		money1.text = str(base1.money)
		hp1.text = str(base1.health)
	else:
		money1.text = str(base2.money)
		hp1.text = str(base2.health)

	if multiplayer.is_server():
		sync_timer += delta
		if sync_timer >= sync_interval:
			sync_timer = 0
			sync_game_state.rpc(base1.money, base1.health, base2.money, base2.health)

	check_win_condition()

func _on_peer_disconnected(id):
	# Handle disconnection
	print("Player ", id, " disconnected")

func add_unit_profile(unit_id):
	var profile = base_profile.instantiate()
	selection.size.x = profile_size
	profile.custom_minimum_size.x = profile_size
	var img = profile.get_node("img")
	var price_tag = profile.get_node("price")
	
	img.texture = mobs[unit_id - 1].pfp
	price_tag.text = str(mobs[unit_id - 1].price)
	profile_holder.add_child(profile)
	unit_profiles.append(profile)

@rpc("authority", "call_local")
func sync_game_state(b1_money: int, b1_health: int, b2_money: int, b2_health: int):
	base1.money = b1_money
	base1.health = b1_health
	base2.money = b2_money
	base2.health = b2_health

@rpc("any_peer", "call_local")
func spawn_mob_rpc(team, zpos, unit_id):
	print("Spawn attempt - Team:", team, " Player ID:", player_id)
	
	# Verify team matches player_id
	if team != player_id:
		print("Spawn rejected - wrong team (team:", team, " player_id:", player_id, ")")
		return
	
	print("Spawn accepted for team:", team)
	var base = base1 if team == 1 else base2
	if mobs[unit_id - 1].price < base.money:
		base.money -= mobs[unit_id - 1].price
		var pos = Vector3()
		
		if team == 1:
			pos = Vector3(base1.position.x + spawn_shift, 0, zpos)
		else:
			pos = Vector3(base2.position.x - spawn_shift, 0, zpos)
		
		# Only server does the actual spawn
		if multiplayer.is_server():
			do_spawn.rpc(unit_id, pos, team)
			sync_game_state.rpc(base1.money, base1.health, base2.money, base2.health)

@rpc("authority", "reliable")
func do_spawn(unit_id: int, pos: Vector3, team: int):
	print("Server spawning unit - ID:", unit_id, " Team:", team, " at pos:", pos)
	var mob = base_unite.instantiate()
	
	# Set properties before spawning
	mob.position = pos
	mob.team = team
	mob.unit_id = unit_id
	
	# Set the network authority
	mob.set_multiplayer_authority(1 if team == 1 else 2)
	
	var model = mobs[unit_id - 1].model.instantiate()
	model.name = "man"
	model.scale = Vector3(0.5, 0.5, 0.5)
	if unit_id == 3:
		model.scale = Vector3(0.7, 0.7, 0.7)
	
	# For team 2, rotate the model 180 degrees
	if team == 2:
		model.rotation_degrees.y = 180
	
	# Set up remaining properties
	mob.model = mobs[unit_id - 1].model
	mob.pfp = mobs[unit_id - 1].pfp
	mob.price = mobs[unit_id - 1].price
	mob.health = mobs[unit_id - 1].health
	mob.damage = mobs[unit_id - 1].damage
	mob.speed = mobs[unit_id - 1].speed
	mob.attack_speed = mobs[unit_id - 1].attack_speed
	mob.hit_range = mobs[unit_id - 1].hit_range
	mob.view_range = mobs[unit_id - 1].view_range
	
	mob.add_child(model)
	
	# Add to scene through normal add_child
	add_child(mob, true)  # true for network ownership
	print("Unit spawned with authority:", mob.get_multiplayer_authority())

@rpc("authority", "call_local")
func game_over(winning_team: int):
	# Show win screen or handle game over
	print("Game Over! Team ", winning_team, " wins!")
	# You can add your win screen logic here

func check_win_condition():
	if multiplayer.is_server():  # Only server checks win condition
		if base1.health <= 0:
			game_over.rpc(2)
		elif base2.health <= 0:
			game_over.rpc(1)

func _input(event):
	if not multiplayer.has_multiplayer_peer():
		return
		
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Use local player_id for team
			spawn_mob_rpc.rpc(player_id, clamp(mouse().z, -spawn_size, spawn_size), selected_unite)

func mouse():
	var space = get_world_3d().direct_space_state
	var plan = Plane(Vector3(0, 1, 0), position.y)
	
	var mspos = get_viewport().get_mouse_position()
	var cam = get_tree().root.get_camera_3d()
	var ray_start = cam.project_ray_origin(mspos)
	var ray_end = ray_start + cam.project_ray_normal(mspos) * 2000
	var ray_array = plan.intersects_ray(ray_start, ray_end)
	return ray_array

func spawn(unit_id, pos, team):
	var mob = base_unite.instantiate()
	
	# Set the network authority
	mob.set_multiplayer_authority(multiplayer.get_unique_id())
	
	var model = mobs[unit_id - 1].model.instantiate()
	model.name = "man"
	model.scale = Vector3(0.5, 0.5, 0.5)
	if (unit_id == 3):
		model.scale = Vector3(0.7, 0.7, 0.7)
	
	# Face the correct direction
	if team == 2:
		model.rotation_degrees.y = 180
	
	mob.position = pos
	mob.team = team
	mob.unit_id = unit_id
	
	mob.model = mobs[unit_id - 1].model
	mob.pfp = mobs[unit_id - 1].pfp
	mob.price = mobs[unit_id - 1].price
	mob.health = mobs[unit_id - 1].health
	mob.damage = mobs[unit_id - 1].damage
	mob.speed = mobs[unit_id - 1].speed
	mob.attack_speed = mobs[unit_id - 1].attack_speed
	mob.hit_range = mobs[unit_id - 1].hit_range
	mob.view_range = mobs[unit_id - 1].view_range
	
	mob.add_child(model)
	add_child(mob)
	return mob
	
@rpc("authority", "reliable")
func spawn_synced(unit_id: int, pos: Vector3, team: int):
	print("Spawning unit - ID:", unit_id, " Team:", team)
	var mob = base_unite.instantiate()
	
	# Set the correct network authority based on team
	mob.set_multiplayer_authority(1 if team == 1 else multiplayer.get_unique_id())
	
	var model = mobs[unit_id - 1].model.instantiate()
	model.name = "man"
	model.scale = Vector3(0.5, 0.5, 0.5)
	if unit_id == 3:
		model.scale = Vector3(0.7, 0.7, 0.7)
	
	# For team 2, rotate the model 180 degrees
	if team == 2:
		model.rotation_degrees.y = 180
	
	mob.position = pos
	mob.team = team
	mob.unit_id = unit_id
	
	mob.model = mobs[unit_id - 1].model
	mob.pfp = mobs[unit_id - 1].pfp
	mob.price = mobs[unit_id - 1].price
	mob.health = mobs[unit_id - 1].health
	mob.damage = mobs[unit_id - 1].damage
	mob.speed = mobs[unit_id - 1].speed
	mob.attack_speed = mobs[unit_id - 1].attack_speed
	mob.hit_range = mobs[unit_id - 1].hit_range
	mob.view_range = mobs[unit_id - 1].view_range
	
	mob.add_child(model)
	
	# Only the server spawns through the MultiplayerSpawner
	if multiplayer.is_server():
		spawner.spawn(mob)
