extends Spatial


var x
var y = 5
var z = -5

onready var a = preload("res://assets/A.tscn")

func _ready():

	_instance_a(a)
	

func _process(delta):

	
	if Input.is_action_pressed("box") and Input.get_action_strength("box") == 1:
		destroy()
		respawn()
	
	

func _instance_a(a):
	var aa = a.instance()
	aa.transform.origin.y = 5
	aa.transform.origin.z = -5
	add_child(aa)



func destroy():

	if self.get_child_count() > 0:
		self.get_child(0).queue_free()
		

func respawn():
	var p = a.instance()
	p.transform.origin.z = -5
	p.transform.origin.y = y
	self.add_child(p)
