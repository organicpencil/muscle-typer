extends TextEdit

var buttonWasPressed = false

# Signals
signal _on_submit(submitText)

# focus is set to text
func _ready():
	self.grab_focus()

# retrieves text
func GetText():
	if(not Input.is_key_pressed( KEY_ENTER )):
		return(self.text)
	return null

## check if you pressed enter to submit phrase
func _process(delta):
	if(Input.is_key_pressed( KEY_ENTER )):
		buttonWasPressed = true
	else:
		if buttonWasPressed:
			emit_signal("_on_submit")
			self.text = ''
			buttonWasPressed = false
