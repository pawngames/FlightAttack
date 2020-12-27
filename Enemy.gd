tool extends Spatial

export var e_mesh:Mesh
export var e_curve:Curve3D

signal enemy_down

func _ready():
	$Path/PathFollow/MeshInstance.mesh = e_mesh
	$Path.curve = e_curve
	pass

func _process(delta):
	$Path/PathFollow.offset += .01
	pass
