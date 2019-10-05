extends Spatial

var _anim_lift
var _anim_grow

var _lifting = false
var _delayed_signal = false

## Important vars
var lift_speed = 0.0 # Set me to determine lifting speed. Normal = 1.0
var arm_size = 0.0 # Ranges from 0.0 to 4.0

### Signals that might be important for sound and scoring
signal lift_start
signal lift_end
signal lift_start_delayed

func _ready():
	_anim_lift = $AnimationPlayer
	_anim_grow = _anim_lift.duplicate()
	add_child(_anim_grow)
	
	_anim_grow.play("grow", -1, 0.0)
	
func _process(delta):
	if !_anim_lift.is_playing():
		if _lifting:
			_lifting = false
			_anim_lift.play("lift_down")
			emit_signal("lift_end")
		else:
			_lifting = true
			_delayed_signal = false
			_anim_lift.play("lift_up", -1, lift_speed)
			emit_signal("lift_start")
			
	elif _anim_lift.current_animation == "lift_up":
		_anim_lift.playback_speed = lift_speed
		
		if !_delayed_signal and _anim_lift.current_animation_position > 0.15:
			_delayed_signal = true
			emit_signal("lift_start_delayed")
			
	_anim_grow.seek(arm_size)