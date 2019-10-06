extends Control

export(NodePath) var status_label
export(NodePath) var message_label
export(NodePath) var input_label
export(NodePath) var line_edit # Hide this offscreen

enum {STATE_PLAYING, STATE_WIN, STATE_LOSE}
var game_state = STATE_PLAYING

var messages_processed = 0
var total_messages # Int set by _retrieve_json
var mistakes = 0
var max_mistakes = 5
var message_text = ""

var good_prefixes = [null, "Totally", "Absolutely"]
var good_statuses = ["Good", "Nice", "Superb", "Excellent", "Fantastic", "Radical", "Wicked", "Bodacious"]
var next_prefix = 0
var next_status = 0

var all_phrases # Array loaded from json

func _ready():
	assert(status_label)
	status_label = get_node(status_label)
	assert(message_label)
	message_label = get_node(message_label)
	assert(input_label)
	input_label = get_node(input_label)
	assert(line_edit)
	line_edit = get_node(line_edit)

	line_edit.connect("text_changed", self, "_on_text_changed")
	line_edit.connect("text_entered", self, "_on_text_entered")
	line_edit.grab_focus()
	
	input_label.bbcode_text = "[color=#ffffff]#[/color]"
	
	_retrieve_json()
	next_message()
	
func _retrieve_json():
	# Check if there is a typer file
	var file = File.new()
	assert(file.file_exists("res://typer/phrases.json"))
	file.open("res://typer/phrases.json", file.READ)
	var json = file.get_as_text()
	var parse = JSON.parse(json)
	all_phrases = parse.result
	total_messages = all_phrases.size()
	file.close()

func next_message():
	if !all_phrases.size():
		message_label.bbcode_text = "Out o' content"
		return false
		
	message_text = all_phrases.pop_front()
	message_label.bbcode_text = "[color=#3399ff]%s[/color]" % message_text
	return true
	
func _on_text_changed(input_text):
	if game_state != STATE_PLAYING:
		return
		
	var bbcode = ""
	for i in range(0, input_text.length()):
		if (i < message_text.length()) and (input_text[i] == message_text[i]):
			bbcode += "[color=#66ff33]%s[/color]" % input_text[i]
		else:
			bbcode += "[color=#ff3300]%s[/color]" % input_text[i]
			
	bbcode += "[color=#ffffff]#[/color]"
	input_label.bbcode_text = bbcode
	
func _on_text_entered(input_text):
	if game_state != STATE_PLAYING:
		return
		
	if input_text == "":
		# Ignore empty in case the keyboard double-pressed
		return
		
	messages_processed += 1
	
	if input_text == message_text:
		var prefix = good_prefixes[next_prefix]
		var status = good_statuses[next_status]
		next_status += 1
		if next_status == good_statuses.size():
			next_status = 0
			next_prefix += 1
			if next_prefix == good_prefixes.size():
				next_prefix = 0
		
		if prefix:
			status = prefix + " " + status.to_lower()
		
		status_label.bbcode_text = "[color=#66ff33]%s[/color]" % status
		
		if messages_processed + 1 == total_messages:
			status_label.bbcode_text += "\n[color=#66ff33]One more to go![/color]"
		elif messages_processed == total_messages:
			status_label.bbcode_text += "\n[color=#66ff33]Victory[/color]"
			game_state = STATE_WIN
			return
		
	else:
		mistakes += 1
		status_label.bbcode_text = "[color=#ff3300]Mistake! %d/%d[/color]" % [mistakes, max_mistakes]
		
		if mistakes + 1 == max_mistakes:
			status_label.bbcode_text += "\n[color=#ff3300]Last chance, buddy.[/color]"
			
		elif mistakes == max_mistakes:
			game_state = STATE_LOSE
			status_label.bbcode_text += "\n[color=#ff3300]Game over[/color]"
			return
			
		if messages_processed + 1 == total_messages:
			status_label.bbcode_text += "\n[color=#66ff33]... but only one more to go[/color]"
		elif messages_processed == total_messages:
			status_label.bbcode_text += "\n[color=#66ff33]... but you still won![/color]"
			game_state = STATE_WIN
			return
		
	line_edit.text = ""
	input_label.bbcode_text = ""
	next_message()