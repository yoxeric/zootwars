extends Node3D

var WIN = preload("res://scenes/win.tscn").instantiate()

@export var base_unite = preload("res://scenes/mob.tscn")
@export var base_profile = preload("res://scenes/ui/unit_profile.tscn")

#  ---------- characters ---------- 3d - pic
# - price - hp - atk - spd - atk spd - atk_rng - view_rng -
var mobs = [Mob.new(preload("res://assets/characters/gaiman.blend"), preload("res://assets/characters/gaiman.png"),
2, 2, 1, 25, 1, 10, 50),
Mob.new(preload("res://assets/characters/yungin.blend"), preload("res://assets/characters/yungin.png"),
4, 1, 1, 30, 0.8, 40, 50),
Mob.new(preload("res://assets/characters/grini.blend"),  preload("res://assets/characters/grini.png"),
6, 5, 2, 20, 1.2, 10, 50),
Mob.new(preload("res://assets/characters/zootman.blend"), preload("res://assets/characters/zootman.png"), 
7, 1, 2, 70, 0.9, 10, 50),
Mob.new(preload("res://assets/characters/weeb.blend"), preload("res://assets/characters/weeb.png"),    
8, 2, 5, 30, 1, 15, 50),
Mob.new(preload("res://assets/characters/zak.blend"), preload("res://assets/characters/zak.png"),     
7, 100, 3, 25, 1, 30, 50),
Mob.new(preload("res://assets/characters/sayad.blend"), preload("res://assets/characters/sayad.png"),   
8, 2, 3, 20, 1, 70, 100),
Mob.new(preload("res://assets/characters/nsab.blend"), preload("res://assets/characters/nsab.png"),    
20, 2, 2, 25, 1, 10, 50),
Mob.new(preload("res://assets/characters/conman.blend"), preload("res://assets/characters/conman.png"), 
8, 4, 4, 20, 1, 10, 50)]


@onready var base1: Node3D = $base1
@onready var base2: Node3D = $base2

@onready var plyr: CharacterBody3D = $plyr
@onready var timer = $Timer

@onready var profile_holder : HBoxContainer = $ui/unites
@onready var selection = $ui/selection

@onready var money1 = $ui/team1/money/money_txt
@onready var money2 = $ui/team2/money/money_txt

@onready var hp1 = $ui/team1/hp/hp_txt
@onready var hp2 = $ui/team2/hp/hp_txt

var unit_profiles = [ ]
@export var profile_size = 100
var selected_unite = 1
var enemy_selected_unite = 1

@export var spawn_shift = 58
@export var spawn_size = 230

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()
	var i = 1
	for x in mobs:
		add_unit_profile(i)
		i += 1

func add_unit_profile(unit_id):
	var profile = base_profile.instantiate()
	selection.size.x = profile_size
	#selection.size.y = profile_size * 3 / 4
	profile.custom_minimum_size.x = profile_size
	var img = profile.get_node("img")
	var price_tag = profile.get_node("price")
	
	img.texture = mobs[unit_id - 1].pfp
	price_tag.text = str(mobs[unit_id - 1].price)
	profile_holder.add_child(profile)
	unit_profiles.append(profile)


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#print("Mouse Click/Unclick at: ", event.position)
			spawn_mob(1, clamp(mouse().z, -spawn_size, spawn_size))
		
	# player
	if Input.is_action_just_pressed("ok"):
		spawn_mob(1, randf() * spawn_size - spawn_size / 2)
	
	# units
	if Input.is_action_just_pressed("1"):
		selected_unite = 1
	if Input.is_action_just_pressed("2"):
		selected_unite = 2
	if Input.is_action_just_pressed("3"):
		selected_unite = 3
	if Input.is_action_just_pressed("4"):
		selected_unite = 4
	if Input.is_action_just_pressed("5"):
		selected_unite = 5
	if Input.is_action_just_pressed("6"):
		selected_unite = 6
	if Input.is_action_just_pressed("7"):
		selected_unite = 7
	if Input.is_action_just_pressed("8"):
		selected_unite = 8
	if Input.is_action_just_pressed("9"):
		selected_unite = 9
	selection.position.x = (selected_unite - 1) * profile_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	money1.text = str(base1.money)
	hp1.text = str(base1.health)
	money2.text = str(base2.money)
	hp2.text = str(base2.health)
	

func mouse():
	var space = get_world_3d().direct_space_state
	var plan = Plane(Vector3(0, 1, 0), position.y)
	
	var mspos = get_viewport().get_mouse_position()
	var cam = get_tree().root.get_camera_3d()
	var ray_start = cam.project_ray_origin(mspos)
	var ray_end = ray_start + cam.project_ray_normal(mspos) * 2000
	var ray_array = plan.intersects_ray(ray_start, ray_end)
	return ray_array
	#if ray_array.has("position"):
		#return ray_array["position"]
	#return Vector3()

func spawn_mob(team, zpos):
	var base = base1
	var selection = selected_unite
	var dir = 1
	if team == 2:
		selection = enemy_selected_unite
		base = base2
		dir = -1
	if mobs[selection - 1].price < base.money:
		base.money -= mobs[selection - 1].price
		var pos = Vector3(base.position.x + spawn_shift * dir, 0,  zpos)
		spawn(selection, pos, team)

func spawn(unit_id, pos, team):
	#var mob = unites[unit_id - 1].instantiate()
	var mob = base_unite.instantiate()
	
	var model = mobs[unit_id - 1].model.instantiate()
	model.name = "man"
	model.scale = Vector3(0.5, 0.5, 0.5)
	if (unit_id == 3):
		model.scale = Vector3(0.7, 0.7, 0.7)
	
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
	return (mob)


func _on_timer_timeout() -> void:
	# Pick random unit the enemy can afford
	var affordable_units = []
	for i in range(mobs.size()):
		if mobs[i].price <= base2.money:
			affordable_units.append(i + 1)
	
	if affordable_units.size() > 0:
		enemy_selected_unite = affordable_units[randi() % affordable_units.size()]
		spawn_mob(2, randf() * spawn_size - spawn_size / 2)