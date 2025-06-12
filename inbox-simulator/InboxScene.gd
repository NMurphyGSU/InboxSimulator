extends Node2D

var json_path = "res://emails.json" #still need to create the JSON file for the emails, so placeholder

var emails: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Read_Messages.visible = false
	$Unread_Messages.visible = true
	$Response.visible = false
	$Answer.visible = false
	$Sent_Items.visible = false
	$Company_Info.visible = false
	$Your_Role.visible = false
	
	#open the file for reading
	var file = FileAccess.open(json_path, FileAccess.READ) #this will call in the JSON file
	assert(file.file_exists(json_path), "File path does not exist") #this will probably trigger for now, until placeholder is filled
	
	#read the content of the json file
	var json = file.get_as_text() 
	var json_object = JSON.new()
	
	#parse the JSON file
	json_object.parse(json)
	
	#Store the parsed data in the content dictionary
	emails = json_object.data
	
	#return emails
	populate_unread_emails()

	print("Loaded emails:", emails.size())
	print("Unread VBox children:", $Unread_Messages/Unread_Vbox.get_child_count())


	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func populate_unread_emails():
	for email in emails:
		if email.read == false:
			var btn = Button.new()
			btn.text = email.subject
			btn.connect("pressed", Callable(self, "_on_email_selected").bind(email))
			$Unread_Messages/Unread_Vbox.add_child(btn)
	
	
func _on_email_selected(email_data):
	var full_text = "[b]From:[/b] %s\n[b]Subject:[/b] %s\n\n%s" % [
		email_data.sender,
		email_data.subject,
		email_data.body
	]
	$Main_Message/Main_Area.bbcode_text = full_text

	# Only move to Read_Vbox if not already read
	if not email_data.read:
		# Create new button in Read_Vbox
		var read_btn = Button.new()
		read_btn.text = email_data.subject
		read_btn.connect("pressed", Callable(self, "_on_email_selected").bind(email_data))
		$Read_Messages/Read_Vbox.add_child(read_btn)

		# Remove the button from Unread_Vbox
		for child in $Unread_Messages/Unread_Vbox.get_children():
			if child.text == email_data.subject:
				child.queue_free()
				break

		# Mark email as read
		email_data.read = true



	
func _on_exit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_read_unread_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$Read_Messages.visible = true
		$Unread_Messages.visible = false
	else:
		$Read_Messages.visible = false
		$Unread_Messages.visible = true
		
	pass # Replace with function body.


func _on_reply_pressed() -> void:
	$Response.visible = true
	pass # Replace with function body.


func _on_close_button_pressed() -> void:
	$Response.visible = false
	$Answer.visible = false
	pass # Replace with function body.


func _on_sent_items_button_pressed() -> void:
	$Sent_Items.visible = true
	$Unread_Messages.visible = false
	$Read_Messages.visible = false
	$Read_Unread.visible = false
	pass # Replace with function body.


func _on_inbox_button_pressed() -> void:
	$Unread_Messages.visible = true
	$Read_Messages.visible = false
	$Read_Unread.visible  = true
	$Sent_Items.visible = false
	pass # Replace with function body.


func _on_company_info_button_pressed() -> void:
	$Company_Info.visible = true
	pass # Replace with function body.



func _on_x_button_pressed() -> void:
	$Company_Info.visible = false
	pass # Replace with function body.
	

func _on_x_button_2_pressed() -> void:
	$Your_Role.visible = false
	pass # Replace with function body.


func _on_your_role_button_pressed() -> void:
	$Your_Role.visible = true
	pass # Replace with function body.


func _on_submit_button_pressed() -> void: #Put info here for submission of answer into attributes calculation
	$Response.visible = false
	#emails.read = true
	pass # Replace with function body.
