extends Spatial

var x
var y = 10
var z
onready var player = preload ("res://Player/Player.tscn")
onready var a = preload("res://assets/A.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():

	_instance_player(player)
	

func _process(delta):

	
	if Input.is_action_pressed("restart") and Input.get_action_strength("restart") == 1:
		destroy()
		respawn()
	
	



func _instance_player(player):
	var p = player.instance()
	p.transform.origin.y = y
	add_child(p)





func destroy():
	x = get_child(0).translation.x
	z = get_child(0).translation.z
	#print(x)
	#print(get_child(1))
	if self.get_child_count() > 0:
		self.get_child(0).queue_free()
		

func respawn():
	var p = player.instance()
	p.transform.origin.x = x
	p.transform.origin.y = 5
	p.transform.origin.z = z
	self.add_child(p)
