extends CharacterBody3D


@onready var camera = $Camera3D

@export var SPEED = 200
@export var zoom = 150
@export var zoom_limit = Vector2(25, 200)
@export var limit = Vector2(300, 200)

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var cam_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	zoom += cam_dir.y
	zoom = clamp(zoom, zoom_limit.x, zoom_limit.y)
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

func constrain_position(pos: Vector3) -> Vector3: 
	pos.x = clampf(pos.x, -limit.x, limit.x) 
	pos.z = clampf(pos.z, -limit.y, limit.y) 
	return pos
