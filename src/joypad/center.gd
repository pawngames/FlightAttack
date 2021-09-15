extends Sprite

onready var deform_vec = self.material.get_shader_param("deform");

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _update_shader(value):
	deform_vec = value
	self.material.set_shader_param("deform", deform_vec)
	pass
