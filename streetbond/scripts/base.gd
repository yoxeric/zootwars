extends Node3D


var health = 50
var damage = 0
var state = 0

var money = 100
var cashflow = 1

@export var team = 1
@onready var timer = $cashTimer

@onready var health_bar: ProgressBar = $Sprite3D/SubViewport/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.max_value = health
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		queue_free()
	

func take_dmg(dmg):
	health -= dmg
	if health_bar.value < dmg:
		dmg = health_bar.value
	health_bar.value = health


func _on_cash_timer_timeout():
	money += cashflow
