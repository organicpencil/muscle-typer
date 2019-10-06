extends Spatial

var _anim_lift
var _anim_grow

var _lifting = false
var _delayed_signal = false
var _weights = 0
var _lift_percent_lerp = 0.0
var _arm_size_lerp = 0.0

## Important vars
#var lift_speed = 0.0 # Set me to determine lifting speed. Normal = 1.0
var growth_delta = 0.1 # Amount to grow with each phrase
var arm_size = 0.0 # Ranges from 0.0 to 1.0 (don't need to touch, change growth_delta instead)
var lift_percent = 0.0 # Ranges from 0.0 to 1.0, should match percent of letters typed

### Signals that might be important for sound and scoring
signal delayed_grunt

const WEIGHT_SCENE = preload("weight.dae")

var next_grunt = 0
var grunts = [preload("res://audio/grunt_sound_pack_1/grunt_1.wav"),
	preload("res://audio/grunt_sound_pack_1/grunt_2.wav"),
	preload("res://audio/grunt_sound_pack_1/grunt_3.wav"),
	preload("res://audio/grunt_sound_pack_1/grunt_4.wav"),
	preload("res://audio/grunt_sound_pack_1/grunt_5.wav"),
	preload("res://audio/grunt_sound_pack_1/grunt_6.wav"),
	preload("res://audio/grunt_sound_pack_1/grunt_7.wav"),
	preload("res://audio/grunt_sound_pack_1/grunt_8.wav"),
	preload("res://audio/grunt_sound_pack_1/grunt_9.wav"),]

func _ready():
	_anim_lift = $AnimationPlayer
	_anim_grow = _anim_lift.duplicate()
	add_child(_anim_grow)
	
	_anim_grow.play("grow", -1, 0.0)
	
	add_weight()
	add_weight()
	add_weight()
	
func add_weight():
	var weight = WEIGHT_SCENE.instance()
	$Armature/Skeleton/ArmR/Spatial/Bar.add_child(weight)
	weight.translation = Vector3(1.2 + 0.3 * _weights, 0.0, 0.0)
	
	weight = WEIGHT_SCENE.instance()
	$Armature/Skeleton/ArmR/Spatial/Bar.add_child(weight)
	weight.translation = Vector3(-1.2 - 0.3 * _weights, 0.0, 0.0)
	
	_weights += 1
	
func _on_lift_success():
	_lifting = false
	_anim_lift.play("lift_down", 0.2)
	lift_percent = 0.0
	arm_size += growth_delta
	
func _on_lift_failure():
	_anim_lift.play("lift_down", 0.2)
	lift_percent = 0.0
	arm_size += growth_delta
	
func _on_lift_progress(percent):
	lift_percent = percent
	
func _process(delta):
	_lift_percent_lerp = lerp(_lift_percent_lerp, lift_percent, 0.1)
	_arm_size_lerp = min(lerp(_arm_size_lerp, arm_size, 0.01), 1.0)
	
	if !_anim_lift.is_playing():
		_lifting = true
		_delayed_signal = false
		_anim_lift.play("lift_up", -1, 0.0)
		
	elif _anim_lift.current_animation == "lift_up":
		_anim_lift.seek(_lift_percent_lerp * 0.7)
		
		if !_delayed_signal and _anim_lift.current_animation_position > 0.3:
			_delayed_signal = true
			emit_signal("delayed_grunt") # Probably does nothing, moved code here
			get_node("AudioStreamPlayer").stream = grunts[next_grunt]
			get_node("AudioStreamPlayer").play()
			if grunts.size() - 1 > next_grunt:
				next_grunt += 1
			
			
	_anim_grow.seek(_arm_size_lerp * 4.0) # The animation is 4 seconds long