extends Node3D


@export var health = 50
var damage = 0

@export var team = 1
@export var money = 100
@export var cashflow = 1
var level = 1
var state = 0

@onready var timer = $cashTimer

@onready var health_team1: ProgressBar = $stats/SubViewport/health
@onready var health_team2: ProgressBar = $stats/SubViewport/health2
var health_bar
@onready var level_bar = $stats/SubViewport/level

# Called when the node enters the scene tree for the first time.
func _ready():
	if team == 1:
		health_bar = health_team1
		health_team2.visible = false
	if team == 2:
		health_bar = health_team2
		health_team1.visible = false
	health_bar.max_value = health
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		queue_free()
		if team == 1:
			get_tree().change_scene_to_file("res://scenes/lose.tscn")
		if team == 2:
			get_tree().change_scene_to_file("res://scenes/win.tscn")
	

func hit_animation():
	pass

func take_dmg(dmg):
	health -= dmg
	if health_bar.value < dmg:
		dmg = health_bar.value
	health_bar.value = health


func _on_cash_timer_timeout():
	money += cashflow
