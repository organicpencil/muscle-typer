extends Node

var cracked = false

var grunts = []

signal start
signal crack

func _ready():
	load_grunts()
	connect("crack", self, "_on_crack")
	
func load_grunts():
	var dir = Directory.new()
	var filepaths = []
	if dir.open("res://grunts/") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".wav"):
				filepaths.append("res://grunts/" + file_name)
				
			file_name = dir.get_next()
			
		filepaths.sort()
		for f in filepaths:
			grunts.append(load(f))
	else:
		print("Error accessing grunts folder")
	
func _on_crack():
	cracked = true