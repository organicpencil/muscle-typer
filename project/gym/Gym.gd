extends Node

func _ready():
	Global.connect("crack", self, "_on_crack")
	if Global.cracked:
		$Crack.show()

func _on_crack():
	# TODO - Play crack sound
	$Crack.show()
