extends Node

var json
var levelPhrases
var currentPhrase
var storedPhrase
var level = 1
var total_phrases = 30

export(NodePath) var player

func _ready():
	assert(player != null)
	player = get_node(player)
	_retrieve_json()

## retrieves json
func _retrieve_json():
	# Check if there is a classes file
	var file = File.new()
	if not file.file_exists("res://TyperModule/typer.json"):
	    print("Missing classes.json file.")
	else:
		file.open("res://TyperModule/typer.json", file.READ)
		var json = file.get_as_text()
		var parse = JSON.parse(json)
		var classDict = parse.result
		_get_level_phrases(classDict)
		file.close()
	pass

## Get list of phrases for specific level
func _get_level_phrases(newDict):
	json = newDict
	for i in range(0,json.size()):
		if(i == level):
			for i in json:
				levelPhrases = json[i]
	# picks a random phrase from an array
	currentPhrase = levelPhrases[(randi() % levelPhrases.size())]
	$CurrentPhrase.text = currentPhrase
	print(currentPhrase)

##
# Goes throught phrase and what you typed and checks correctness
##
func _parse_text(phrase):
	var currentPhraseToMatch = currentPhrase.split(" ")
	var splitPhrase = phrase.split(" ")
	var matches = 0
	var matchingOrder = []
	var primaryCount = 0

	#check for matches, check for order
	for word in currentPhraseToMatch:
		var secondaryCount = 0
		for otherWord in splitPhrase:
			if word.matchn(otherWord):
				matches+=1
				if primaryCount == secondaryCount:
					matchingOrder.append(true)
				else:
					matchingOrder.append(false)
			secondaryCount+=1
		primaryCount+=1
	return([currentPhraseToMatch.size(), matches, matchingOrder])

##
# @params - checks (number of words, num of matches, in-order words)
# @returns true for success, false for failure
##
func _check_complete(checks):
	# checks if number of words match the number of word matches
	if checks[0] == checks[1]:
		# checks if all words are in order (in-order = true)
		for order in checks[2]:
			if order == false:
				return false
		return true
		
func _check_accuracy(phrase : String):
	var failures = 0
	for i in range(0, phrase.length()):
		if i >= currentPhrase.length() or phrase[i] != currentPhrase[i]:
			failures += 1
			
	return int(max(failures, 0))

## text is stored and changed
func _on_TextEdit_text_changed():
	var phrase = self.get_child(0).GetText();
	if phrase == null:
		phrase = storedPhrase
	else:
		storedPhrase = phrase
	_parse_text(phrase);
	
	var failures = _check_accuracy(phrase)
	player.lift_percent = float(phrase.length() - failures) / float(currentPhrase.length())

## On click of enter it checks if its success or failure
func _on_TextEdit__on_submit():
	if _check_complete(_parse_text(storedPhrase)):
		print("Success!")
		player.lift_success()
	else:
		print("Failure")
		player.lift_failure()
	player.arm_size += 1.0 / total_phrases
	currentPhrase = levelPhrases[(randi() % levelPhrases.size())]
	$CurrentPhrase.text = currentPhrase
	print(currentPhrase)
	pass
