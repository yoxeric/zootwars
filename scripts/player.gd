extends CharacterBody3D


@onready var camera = $Camera3D

@export var SPEED = 200
@export var zoom = 150
@export var zoom_limit = Vector2(25, 200)
@export var limit = Vector2(300, 200)

var touch_points : Dictionary = {}
var offset
var direction

var pan_speed = 1
var zoom_speed = 1
var rot_speed = 1

@export var cam_pan : bool
@export var cam_zoom : bool
@export var cam_rot : bool

var start_pos
var start_dis
var start_zom
var start_angle = 0

var current_angle = 0
var current_dis = 0
var current_pos = 0

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var cam_dir := Input.get_vector("left", "right", "up", "down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	zoom = clamp(zoom + cam_dir.y, zoom_limit.x, zoom_limit.y)
	camera.position = Vector3(0, zoom, zoom)
	rotation.y -= cam_dir.x / 20
	
	#camera.global_position = constrain_position(camera.global_position)
	global_position = constrain_position(global_position)
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event):
	if event is InputEventScreenTouch:
		brka(event)
	if event is InputEventScreenDrag:
		swip(event)
	#if event is InputEventMultiScreenDrag:
		##direction += event.relative
		#print("S direction : ", event.relative)
		#direction = (transform.basis * Vector3(event.relative.x, 0, event.relative.y)).normalized()
	#if event is InputEventScreenPinch:
		#zoom -= event.relative
	#if event is InputEventScreenTwist:
		#print("T direction : ", event.relative)
		#rotation.y -= event.relative * rot_speed
		

func brka(event):
	if event.pressed:
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)
	
	if touch_points.size() == 0:
		direction = 0
	if touch_points.size() == 1:
		print("on click")
	if touch_points.size() == 2:
		var tp = touch_points.values()
		#start_pos = (tp[0] + tp[1]) / 2
		start_dis = tp[0].distance_to(tp[1])
		start_zom = zoom
		start_angle = get_angle(tp[0], tp[1])
		print("two click")
		
	if touch_points.size() < 2:
		start_dis = 0

func swip(event):
	touch_points[event.index] = event.position
		
	if touch_points.size() == 1:
		print("on swip")
		if cam_pan :
			offset = event.relative * pan_speed
			direction = (transform.basis * Vector3(offset.x, 0, offset.y)).normalized()
		
	if touch_points.size() == 2:
		print("two swip")
		var tp = touch_points.values()
		#current_pos = (tp[0] + tp[1]) / 2
		current_dis = tp[0].distance_to(tp[1])
		current_angle = get_angle(tp[0], tp[1])
		var zomfac = start_dis / current_dis
		
		#if cam_pan :
			#offset = event.relative * pan_speed
			##offset = (current_pos - start_pos) * pan_speed
			#direction = (transform.basis * Vector3(offset.x, 0, offset.y)).normalized()
		if cam_zoom :
			zoom = start_zom * zomfac
		if cam_rot :
			rotation.y += ( current_angle - start_angle ) * rot_speed
			start_angle = current_angle
		

func constrain_position(pos: Vector3) -> Vector3: 
	pos.x = clampf(pos.x, -limit.x, limit.x) 
	pos.z = clampf(pos.z, -limit.y, limit.y) 
	return pos

func get_angle(p1, p2):
	var delta = p2 - p1
	return fmod((atan2(delta.y, delta.x) + PI), (2 * PI))
