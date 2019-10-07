extends Spatial

export(NodePath) var screen
var next_motivation = 2

func _ready():
	screen = get_node(screen)
	hide()
	Global.connect("lose", self, "lose")
	Global.connect("victory", self, "victory")
	Global.connect("motivate", self, "motivate")
	$Timer.connect("timeout", self, "hide")

func _process(delta):
	#rotate_object_local(Vector3(0, 1, 0), -0.03)
	pass
	
func lose():
	show()
	$Timer.wait_time = $LoseSound.stream.get_length()
	$Timer.start()
	$LoseSound.play()
	
func victory():
	show()
	$Timer.wait_time = $VictorySound.stream.get_length()
	$Timer.start()
	$VictorySound.play()
	
func motivate():
	show()
	var sound = get_node("Motivation%d" % next_motivation)
	next_motivation += 1
	if next_motivation > 10:
		next_motivation = 2
		
	$Timer.wait_time = sound.stream.get_length()
	$Timer.start()
	sound.play()