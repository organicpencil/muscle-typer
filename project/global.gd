extends Node

var cracked = false

signal start
signal crack

func _ready():
	connect("crack", self, "_on_crack")
	
func _on_crack():
	cracked = true