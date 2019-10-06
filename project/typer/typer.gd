extends Control

export(NodePath) var status_label
export(NodePath) var message_label
export(NodePath) var input_label
export(NodePath) var line_edit # Hide this offscreen
export(NodePath) var timer
export(NodePath) var timer_progress

enum {STATE_PLAYING, STATE_WIN, STATE_LOSE, STATE_PREGAME, STATE_BETWEEN}
var game_state = STATE_PREGAME

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

signal timeout_value # emits float range 0-100 for timeout progress
signal typing_progress(percent) # emits float range 0-1 for lift progress
signal typing_finished
signal typing_failed

func _ready():
	status_label = get_node(status_label)
	message_label = get_node(message_label)
	input_label = get_node(input_label)
	line_edit = get_node(line_edit)
	timer = get_node(timer)
	timer_progress = get_node(timer_progress)

	line_edit.connect("text_changed", self, "_on_text_changed")
	line_edit.connect("text_entered", self, "_on_text_entered")
	line_edit.grab_focus()
	
	timer.connect("timeout", self, "_on_timeout")
	
	_retrieve_json()
	
	Global.connect("start", self, "_on_start")
	
func _on_start():
	if game_state != STATE_PLAYING:
		game_state = STATE_PLAYING
		input_label.bbcode_text = " [color=#ffffff]#[/color]"
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
	
func _on_timeout():
	_on_text_entered(null)
	# TODO - Drop or something

func next_message():
	if !all_phrases.size():
		message_label.bbcode_text = "[color=#ff3300]-Random error, how to reproduce?[/color]"
		print("This shouldn't happen")
		return false
		
	input_label.bbcode_text = " [color=#ffffff]#[/color]"
	message_text = all_phrases.pop_front()
	message_label.bbcode_text = " [color=#3399ff]%s[/color]" % message_text
	timer.start()
	emit_signal("typing_started")
	return true
	
func _on_text_changed(input_text):
	if game_state != STATE_PLAYING:
		line_edit.text = ""
		return
		
	var bbcode = " "
	for i in range(0, input_text.length()):
		if (i < message_text.length()) and (input_text[i] == message_text[i]):
			bbcode += "[color=#66ff33]%s[/color]" % input_text[i]
		else:
			bbcode += "[color=#ff3300]%s[/color]" % input_text[i]
			
	bbcode += "[color=#ffffff]#[/color]"
	input_label.bbcode_text = bbcode
	emit_signal("typing_progress", min(float(input_text.length()) / float(message_text.length()), 1.0))
	
func _on_text_entered(input_text):
	if game_state != STATE_PLAYING:
		return
		
	if input_text == "":
		# Ignore empty in case the keyboard double-pressed
		return
		
	messages_processed += 1
	timer.stop()
	
	if input_text == message_text:
		emit_signal("typing_finished")
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
		
		if messages_processed + 1 == total_messages:
			status_label.bbcode_text = " [color=#66ff33]One more to go![/color]"
		elif messages_processed == total_messages:
			status_label.bbcode_text = " [color=#66ff33]Victory[/color]"
			game_state = STATE_WIN
		else:
			status_label.bbcode_text = " [color=#66ff33]%s[/color]" % status
		
	else:
		mistakes += 1
		emit_signal("typing_failed")
		
		if input_text == null:
			status_label.bbcode_text = " [color=#ff3300]Too slow, ye dropped it. %d/%d[/color]" % [mistakes, max_mistakes]
		else:
			status_label.bbcode_text = " [color=#ff3300]Mistake! %d/%d[/color]" % [mistakes, max_mistakes]
		
		if mistakes + 1 == max_mistakes:
			status_label.bbcode_text += "\n [color=#ff3300]Last chance, buddy.[/color]"
			
		elif mistakes == max_mistakes:
			game_state = STATE_LOSE
			status_label.bbcode_text += "\n [color=#ff3300]Game over[/color]"
			
		elif messages_processed + 1 == total_messages:
			status_label.bbcode_text += "\n [color=#66ff33]... but only one more to go[/color]"
		elif messages_processed == total_messages:
			status_label.bbcode_text += "\n [color=#66ff33]Still good enough. Congrats.[/color]"
			game_state = STATE_WIN
		
	if game_state == STATE_PLAYING:
		game_state = STATE_BETWEEN
		line_edit.text = ""
		input_label.bbcode_text = ""
		message_label.bbcode_text = ""
		yield(get_tree().create_timer(2.0), "timeout")
		if game_state == STATE_BETWEEN:
			game_state = STATE_PLAYING
			next_message()
	
func _process(delta):
	if game_state == STATE_WIN:
		timer_progress.value = 0
	else:
		timer_progress.value = ((timer.wait_time - timer.time_left) / timer.wait_time) * 100.0
		
	emit_signal("timeout_value", timer_progress.value)