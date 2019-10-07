extends RigidBody

var fully_charged = false

func _ready():
	$Timer.connect("timeout", self, "queue_free")
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if fully_charged and !Global.cracked:
		Global.emit_signal("crack")