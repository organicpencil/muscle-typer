extends Spatial

var anim_lift
var anim_grow

var lifting = false
var grunted = false

## Important vars
var lift_speed = 0.0 # Set me to determine lifting speed. Normal = 1.0
var arm_size = 0.0 # Ranges from 0.0 to 4.0

### Signals that might be important for sound and scoring
signal lift_start
signal lift_end
signal lift_start_delayed

func _ready():
	anim_lift = $AnimationPlayer
	anim_grow = anim_lift.duplicate()
	add_child(anim_grow)
	
	anim_grow.play("grow", -1, 0.0)
	
func _process(delta):
	if !anim_lift.is_playing():
		if lifting:
			lifting = false
			anim_lift.play("lift_down")
			emit_signal("lift_end")
		else:
			lifting = true
			grunted = false
			anim_lift.play("lift_up", -1, lift_speed)
			emit_signal("lift_start")
			
	elif anim_lift.current_animation == "lift_up":
		anim_lift.playback_speed = lift_speed
		
		if !grunted and anim_lift.current_animation_position > 0.15:
			grunted = true
			emit_signal("lift_start_delayed")
			
	anim_grow.seek(arm_size)