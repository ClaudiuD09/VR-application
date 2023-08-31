extends KinematicBody

export var max_speed = 20
export var acceleration = 60
export var friction = 50
export var air_firction = 10
export var jump_impulse = 20
export var gravity = -20

export var mouse_sensitvity = .1
export var controller_sensitivity = 2

export (int, 0, 10) var push = 1

var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO

onready var head = $Head

var hoist := Vector3()
var is_flying = false
var test = true

var direction := Vector3()
var dir = Vector3.ZERO
var on = 0

onready var camera = $Head/ARVROrigin/ARVRCamera
onready var cam = camera

#raycast:
onready var hand = $Head/ARVROrigin/ARVRCamera/spw
onready var reach = $Head/ARVROrigin/ARVRCamera/RayCast
var spw : Spatial
var drop : Spatial
onready var vad = $Control

onready var A = preload("res://assets/A.tscn")
onready var AHR = preload("res://assets/AHR.tscn")





func _ready():
	randomize()
	var arvr_interface = ARVRServer.find_interface("Native mobile")
	if arvr_interface and arvr_interface.initialize():
		get_viewport().arvr = true
	direction = Vector3.BACK.rotated(Vector3.UP, head.global_transform.basis.get_euler().y)
	set_physics_process(true)




func _input(event):
	if event.is_action_pressed("stop_gravity"):
		gravity = 0
		velocity.y = 0
	if event.is_action_pressed("resume_gravity"):
		velocity.y = 0
		gravity = -20
		
	if event.is_action_pressed("toggle_gravity"):
		if event.get_action_strength("toggle_gravity") == 1:
			if not is_flying:
				is_flying = true
			else:
				is_flying = false


func _physics_process(delta):
	var input_vector = get_input_vector()
	
	var direction = get_direction(input_vector) 

	
	if Input.is_action_just_pressed("cam") and test == true:
		test=false
	elif Input.is_action_just_pressed("cam") and test == false:
		test=true
		
		
	if test == true:
		if on != 0 :
			direction = get_direction(input_vector) 
		
		apply_movement(direction, delta)
		apply_friction(direction, delta)
		
	else:
		on = 1
		direction = get_direction_joy(input_vector) * 2
		apply_movement_joy(direction, delta)
		apply_friction(direction, delta)

	
	apply_gravity(delta)
	jump()
	apply_controller_rotation()
	head.rotation.x = clamp(head.rotation.x, deg2rad(-75), deg2rad(75))
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true, 4, .785398, false)
	
	
	
	if Input.is_action_pressed("hoist") || Input.is_action_pressed("sink"):
		hoist = Vector3(
			0,
			Input.get_action_strength("hoist") - Input.get_action_strength("sink"),
			0
		)
		var v = move_and_slide(hoist * 10)
	
	
	
	#raycast
	if reach.is_colliding():
		if reach.get_collider().get_name() == "A":
			vad.visible=true
			spw = AHR.instance()
		
		else:
			spw = null
			vad.visible=false
			
	
	if hand.get_child(0)!=null:
		if hand.get_child(0).get_name() == "AHR":
			drop = A.instance()
	else:
		drop = null
	
	
	if Input.is_action_just_pressed("interact"):
		
		if spw != null:
			
			if hand.get_child(0) !=null:
				
				get_parent().add_child(spw)
				drop.global_transform = hand.global_transform
				drop.dropped = true
				hand.get_child(0).queue_free()
			reach.get_collider().queue_free()
			hand.add_child(spw)
			spw.rotation = hand.rotation
	
	
	if Input.is_action_just_pressed("drop"):
		if hand.get_child(0)!=null:
			
			get_parent().add_child(drop)
			drop.global_transform = hand.global_transform
			drop.dropped = true
			hand.get_child(0).queue_free()










func get_input_vector():
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	return input_vector.normalized() if input_vector.length() > 1 else input_vector





func get_direction(input_vector):
	
	direction = (input_vector.x * camera.transform.basis.x) + (input_vector.z * camera.transform.basis.z)
	#print(camera.transform.basis.x , camera.transform.basis.z , camera.transform.basis)

	return direction


func get_direction_joy(input_vector):
	
	
	direction = (input_vector.x * transform.basis.x) + (input_vector.z * transform.basis.z)
	return direction




	
func apply_movement(direction, delta):
	if direction != Vector3.ZERO:
		velocity.x = velocity.move_toward(direction * max_speed, acceleration * delta).x
		velocity.z = velocity.move_toward(direction * max_speed, acceleration * delta).z



func apply_movement_joy(direction, delta):
	if direction != Vector3.ZERO:
		velocity.x = velocity.move_toward(direction * max_speed, acceleration * delta).x
		velocity.z = velocity.move_toward(direction * max_speed, acceleration * delta).z






func apply_friction(direction, delta):
	if direction == Vector3.ZERO:
		if is_on_floor():
			velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		else:
			velocity.x = velocity.move_toward(Vector3.ZERO, air_firction * delta).x
			velocity.z = velocity.move_toward(Vector3.ZERO, air_firction * delta).z
			
			
func apply_gravity(delta):
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, gravity, jump_impulse)
	
	
func update_snap_vector():
	snap_vector = -get_floor_normal() if is_on_floor() else Vector3.DOWN
	
	
func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap_vector = Vector3.ZERO
		velocity.y = jump_impulse
	if Input.is_action_just_released("jump") and velocity.y > jump_impulse / 2:
		velocity.y = jump_impulse / 2


func apply_controller_rotation():
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")

	if InputEventJoypadMotion and test == false:
		
		
		rotate_y(deg2rad(-axis_vector.x) * controller_sensitivity)
		head.rotate_x(deg2rad(-axis_vector.y) * controller_sensitivity)




