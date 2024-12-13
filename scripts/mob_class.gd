extends CharacterBody3D

class_name Mob

var unit_id = 1
var model
var pfp
var smiya

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

func _init(mdl, pic, smyto, p, hlt, dmg, sp, asp, r, vr):
	model = mdl
	pfp = pic
	smiya = smyto
	price = p
	health = hlt
	damage = dmg
	speed = sp
	attack_speed = asp
	hit_range = r
	view_range = vr

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
