extends RigidBody


var dropped = false
var dropp = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if dropped == true:
		apply_impulse(transform.basis.z, -transform.basis.z*10)
		apply_impulse(transform.basis.y, -transform.basis.y*2)
		dropped = false
	
	if dropp == true:
		apply_impulse(transform.basis.y, -transform.basis.y*2)
		dropp = false
