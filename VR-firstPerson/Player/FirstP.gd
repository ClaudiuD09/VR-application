extends KinematicBody



var is_flying = false

var velocity := Vector3()
var hoist := Vector3()
var gravity = 10
var fly = true

export var mouse_sensitvity = .1
export var controller_sensitivity = 3

onready var head = $Head


var direction := Vector3()
onready var camera = $Head/ARVROrigin/ARVRCamera



func _ready() -> void:
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
		gravity = 10
		
	if event.is_action_pressed("toggle_gravity"):
		if event.get_action_strength("toggle_gravity") == 1:
			if not is_flying:
				is_flying = true
			else:
				is_flying = false


	if event.is_action_pressed("jump"):
		if event.get_action_strength("jump") == 1:
			velocity.y = 10


func _physics_process(delta) -> void:	


	apply_controller_rotation()
	
	if is_on_floor() and velocity.y < 0:
		velocity.y = 0
	
	
	
	var forward = -camera.transform.basis.z.normalized()
	
	
	
	
	if Input.is_action_pressed("hoist") || Input.is_action_pressed("sink"):
		hoist = Vector3(
			0,
			Input.get_action_strength("hoist") - Input.get_action_strength("sink"),
			0
		)
		var v = move_and_slide(hoist * 10)
	
	if Input.is_action_pressed("forward"):
		move_and_slide(forward * 10) 
	if Input.is_action_pressed("backward"):
		var backward = -forward
		move_and_slide(backward * 10) 

	if Input.is_action_pressed("left"):
		move_and_slide(-forward.cross(Vector3.UP) * 10)
	if Input.is_action_pressed("right"):
		move_and_slide(forward.cross(Vector3.UP) * 10)
	
	move_and_slide(velocity * 1)
	



func apply_gravity(delta):
	pass



func apply_controller_rotation():
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if InputEventJoypadMotion:
		head.rotate_y(deg2rad(-axis_vector.x) * controller_sensitivity)
		
