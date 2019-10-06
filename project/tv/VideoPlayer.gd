extends VideoPlayer

func _ready():
	connect("finished", self, "play")
