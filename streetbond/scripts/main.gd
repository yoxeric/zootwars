extends Node3D

@export var unites = [preload("res://scenes/characters/roadman.tscn"),
 preload("res://scenes/characters/yungin.tscn"),
 preload("res://scenes/characters/lgrini.tscn"),
 preload("res://scenes/characters/zootman.tscn"),
 preload("res://scenes/characters/weeb.tscn"),
 preload("res://scenes/characters/zak.tscn"),
 preload("res://scenes/characters/sayad.tscn"),
 preload("res://scenes/characters/nsab.tscn"),
 preload("res://scenes/characters/conman.tscn")]

@export var unite_price = [2,
3, 
5,
4,
10,
30,
12,
16,
20]

@onready var base1: Node3D = $base1
@onready var base2: Node3D = $base2

@onready var plyr: CharacterBody3D = $plyr
@onready var timer = $Timer
@onready var money1 = $team1/money/money_txt
@onready var money2 = $team2/money/money_txt
@onready var selection = $selection

@onready var hp1 = $team1/hp/hp_txt
@onready var hp2 = $team2/hp/hp_txt

var selected_unite = 1
var enemy_selected_unite = 1
var spawn_shift = 22

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#print("Mouse Click/Unclick at: ", event.position)
			if unite_price[selected_unite - 1] < base1.money:
				base1.money -= unite_price[selected_unite - 1]
				spawn(selected_unite, Vector3(base1.position.x + spawn_shift, 0,  mouse().z), 1)
		
	# player
	if Input.is_action_just_pressed("ok"):
		if unite_price[selected_unite - 1] < base1.money:
			base1.money -= unite_price[selected_unite - 1]
			var mob = spawn(selected_unite, Vector3(base1.position.x + spawn_shift, 0,  randf() * 200 - 100), 1)
	
	#print("team 1 money = ", base1.money)
	#print("team 2 money = ", base2.money)
	money1.text = str(base1.money)
	hp1.text = str(base1.health)
	money2.text = str(base2.money)
	hp2.text = str(base2.health)
	
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
	selection.position.x = (selected_unite - 1) * 60

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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

func spawn(unit, pos, team):
	var mob = unites[unit - 1].instantiate()
	mob.position = pos
	mob.team = team
	#mob.set_collision_layer_value(team)
	
	add_child(mob)
	return (mob)


func _on_timer_timeout() -> void:
	if (unite_price[selected_unite - 1] < base2.money):
		var mob = spawn(enemy_selected_unite, Vector3(base2.position.x - spawn_shift, 0,  randf() * 200 - 100), 2)
		base2.money -= unite_price[selected_unite - 1]
