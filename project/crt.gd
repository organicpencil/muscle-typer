extends Spatial

export(NodePath) var screen

func _ready():
	screen = get_node(screen)

func _process(delta):
	rotate_object_local(Vector3(0, 1, 0), -0.03)