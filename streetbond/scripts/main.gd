extends Node3D

@export var Warrior: PackedScene = preload("res://scenes/warrior.tscn")
const Enemy = preload("res://scenes/enemy.tscn")

@onready var base1: Node3D = $base1
@onready var base2: Node3D = $base2

@onready var plyr: CharacterBody3D = $plyr
@onready var timer: Timer = $base2/Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# player
	if Input.is_action_just_pressed("ok"):
		spawn()
	
	

func spawn():
	var mob = Warrior.instantiate()

	mob.position = Vector3(base1.position.x + 20, 1,  randf() * 200 - 100)
	mob.is_enemy = 0

	#mob.set_name("man")
	add_child(mob)

func spawn_enemy():
	var mob = Enemy.instantiate()

	mob.position = Vector3(base2.position.x - 20, 1,  randf() * 200 - 100)
	mob.is_enemy = 1

	#mob.set_name("mob")
	add_child(mob)


func _on_timer_timeout() -> void:
	spawn_enemy()
