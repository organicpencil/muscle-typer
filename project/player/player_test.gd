extends Node

func _process(delta):
	$Player.arm_size = min($Player.arm_size + delta, 4.0)
	$Player.lift_speed = rand_range(0.0, 3.0)