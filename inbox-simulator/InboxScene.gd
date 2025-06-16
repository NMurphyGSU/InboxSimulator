extends Node2D

var json_path = "res://emails.json"
var companyinfo_path = "res://companyinf.json"
var yourrole_path = "res://yourrole.json"
var emails: Array = []
var current_email = null
var companyinfo = ""
var role = ""

func _ready():
	$Read_Messages.visible = false
	$Unread_Messages.visible = true
	$Response.visible = false
	$Answer.visible = false
	$Sent_Items.visible = false
	$Company_Info.visible = false
	$Your_Role.visible = false

	var file = FileAccess.open(json_path, FileAccess.READ)
	assert(file.file_exists(json_path), "File path does not exist")

	var json = file.get_as_text()
	var json_object = JSON.new()
	json_object.parse(json)
	emails = json_object.data
	populate_unread_emails()
	update_email_counters()

	var info = FileAccess.open(companyinfo_path, FileAccess.READ)
	assert(info.file_exists(companyinfo_path), "File path does not exist")

	companyinfo = info.get_as_text()
	populate_company_info()
	
	var yourrole = FileAccess.open(yourrole_path, FileAccess.READ)
	assert(yourrole.file_exists(yourrole_path), "File path does not exist")
	
	role = yourrole.get_as_text()
	populate_yourrole()

func _process(delta: float) -> void:
	pass

func populate_company_info():
	var label = $Company_Info/Company_Info_Message
	label.clear()

	if companyinfo:
		label.append_text("[color=#4EC1E0]%s[/color]" % companyinfo)
	else:
		label.append_text("[i][color=gray]No company info available.[/color][/i]")
		
func populate_yourrole():
	var label = $Your_Role/Your_Role_Message
	label.clear()

	if role:
		label.append_text("[color=#4EC1E0]%s[/color]" % role)
	else:
		label.append_text("[i][color=gray]No company info available.[/color][/i]")		
	
func populate_unread_emails(): #the initial population of the emails into the game
	for email in emails:
		if email.read == false:
			var email_container = VBoxContainer.new()

			var sender_label = Label.new()
			sender_label.text = email.sender
			sender_label.add_theme_font_size_override("font_size", 14)
			sender_label.add_theme_constant_override("margin_left", 10)
			email_container.add_child(sender_label)

			var subject_label = Label.new()
			subject_label.text = email.subject
			subject_label.add_theme_font_size_override("font_size", 10)
			subject_label.add_theme_constant_override("margin_left", 10)
			email_container.add_child(subject_label)

			var panel = Panel.new()
			panel.custom_minimum_size = Vector2(0, 50)
			panel.connect("gui_input", Callable(self, "_on_email_click").bind(email))
			panel.add_child(email_container)
			panel.mouse_filter = Control.MOUSE_FILTER_STOP

			$Unread_Messages/Unread_Vbox.add_child(panel)

func _on_email_selected(email_data): #when an email is selected
	current_email = email_data
	var full_text = "[color=black][b]From:[/b] %s\n[b]Subject:[/b] %s\n\n%s[/color]" % [
		email_data.sender,
		email_data.subject,
		email_data.body
	]
	$Main_Message/Main_Area.bbcode_text = full_text

	if not email_data.read:
		var email_container = VBoxContainer.new()

		var sender_margin = MarginContainer.new()
		sender_margin.add_theme_constant_override("margin_left", 10)
		var sender_label = Label.new()
		sender_label.text = current_email.sender
		sender_label.add_theme_font_size_override("font_size", 14)
		sender_margin.add_child(sender_label)
		email_container.add_child(sender_margin)

		var subject_margin = MarginContainer.new()
		subject_margin.add_theme_constant_override("margin_left", 10)
		var subject_label = Label.new()
		subject_label.text = current_email.subject
		subject_label.add_theme_font_size_override("font_size", 10)
		subject_margin.add_child(subject_label)
		email_container.add_child(subject_margin)

		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(0, 50)
		panel.connect("gui_input", Callable(self, "_on_email_click").bind(email_data))
		panel.add_child(email_container)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP

		$Read_Messages/Read_Vbox.add_child(panel)

		for child in $Unread_Messages/Unread_Vbox.get_children():
			if child.get_child_count() > 0:
				var container = child.get_child(0)
				if container is VBoxContainer and container.get_child_count() > 1:
					var subject_check = container.get_child(1)
					if subject_check is Label and subject_check.text == email_data.subject:
						child.queue_free()
						break

		email_data.read = true
		update_email_counters()

func _on_email_click(event: InputEvent, email_data): #when the user clicks the emails
	if event is InputEventMouseButton and event.pressed:
		_on_email_selected(email_data)

func update_email_counters(): #handles the counters on the side panel
	var inbox_count = 0
	var sent_count = 0

	for email in emails:
		if email.get("answered", false):
			sent_count += 1
		else:
			inbox_count += 1

	$Side_Panel/Inbox_Number.text = str(inbox_count)
	$Side_Panel/Sent_Items_Number.text = str(sent_count)



func _on_submit_button_pressed() -> void: #handles what happens when the user answers the emails **probably put attribute info here**
	$Response.visible = false
	$Answer.visible = false

	if current_email and not current_email["answered"]:

		current_email.answered = true


		var unread_box = $Unread_Messages/Unread_Vbox
		var read_box = $Read_Messages/Read_Vbox

		for box in [unread_box, read_box]:
			for child in box.get_children():
				if child.get_child_count() > 0:
					var container = child.get_child(0)
					if container is VBoxContainer and container.get_child_count() > 1:
						var subject_check = container.get_child(1)
						if subject_check is MarginContainer and subject_check.get_child_count() > 0:
							var subject_check_label = subject_check.get_child(0)
							if subject_check_label is Label and subject_check_label.text == current_email.subject:
								child.queue_free()
								break

		var email_container = VBoxContainer.new()

		var sender_margin = MarginContainer.new()
		sender_margin.add_theme_constant_override("margin_left", 10)
		var sender_label = Label.new()
		sender_label.text = current_email.sender
		sender_label.add_theme_font_size_override("font_size", 14)
		sender_margin.add_child(sender_label)
		email_container.add_child(sender_margin)

		var subject_margin = MarginContainer.new()
		subject_margin.add_theme_constant_override("margin_left", 10)
		var subject_label = Label.new()
		subject_label.text = current_email.subject
		subject_label.add_theme_font_size_override("font_size", 10)
		subject_margin.add_child(subject_label)
		email_container.add_child(subject_margin)

		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(0, 50)
		panel.add_child(email_container)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

		$Sent_Items/Sent_Vbox.add_child(panel)

		update_email_counters()


func _on_exit_button_pressed() -> void: #button to quit the game
	get_tree().quit()

func _on_read_unread_toggled(toggled_on: bool) -> void: #flips back and forth between read and unread 
	$Read_Messages.visible = toggled_on
	$Unread_Messages.visible = not toggled_on

func _on_reply_pressed() -> void: #when the reply button is pressed
	$Response.visible = true

func _on_close_button_pressed() -> void: #when the close button is pressed
	$Response.visible = false
	$Answer.visible = false

func _on_sent_items_button_pressed() -> void: #sent items button pressed
	$Sent_Items.visible = true
	$Unread_Messages.visible = false
	$Read_Messages.visible = false
	$Read_Unread.visible = false
	$Your_Role.visible = false
	$Company_Info.visible = false

func _on_inbox_button_pressed() -> void: #inbox button pressed
	$Unread_Messages.visible = true
	$Read_Messages.visible = false
	$Read_Unread.visible  = true
	$Sent_Items.visible = false
	$Company_Info.visible = false
	$Your_Role.visible = false

func _on_company_info_button_pressed() -> void: #company info pressed
	$Company_Info.visible = true
	$Your_Role.visible = false

func _on_x_button_pressed() -> void: #xbutton pressed
	$Company_Info.visible = false

func _on_x_button_2_pressed() -> void: #xbutton2 pressed
	$Your_Role.visible = false

func _on_your_role_button_pressed() -> void: #your role button pressed
	$Your_Role.visible = true
	$Company_Info.visible = false
