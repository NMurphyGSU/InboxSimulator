extends Node2D

#-----Dummy copy for testing-------------------------------------
#var json_path = "res://emails.json"
var companyinfo_path = "res://companyinf.json" #keep this for now
var yourrole_path = "res://yourrole.json" #keep this for now

#var emails: Array = []
#var current_email = null
var companyinfo = ""
var role = ""
#----------------------------------------------------------------

#-----Sample data for functionality------------------------------
var dialogue_path = "res://sample-data/dialog-tree.json" #dialogue tree JSON file
var trees: Array = []
var branches: Array = []
var from = null
var to = null
var current_node_id
var correct
var check = ""

var questions_path = "res://sample-data/questions.json" #questions JSON file
var emails: Array = []
var email
var current_email = null
var scenario_id = 1 #do we want this assigned?
var questions
var id
var sender_id
var subject = ""
var question = ""
var randomize_answers = true
var answers
var text = ""
var criteria = ""

var scenario_path = "res://sample-data/scenario.json" #scenario JSON file
var scenario: Array = [] #criteria in dictionary
var scenario_name  = ""
var show_end_results = true #Will allow students to see or not to see results

var senders_path = "res://sample-data/senders.json" #senders JSON file
var senders = []
var sender_name
var title = ""
var color #This should be a circle in this color next to the sender's name- save as an array and then select the color from there
var sender_lookup = {}
var sid
#---------------------------------------------------------------------------------------------------

func _ready():
	$Read_Messages.visible = false
	$Unread_Messages.visible = true
	$Response.visible = false
	$Answer.visible = false
	$Sent_Items.visible = false
	$Company_Info.visible = false
	$Your_Role.visible = false


#-----Testing---------------------------------------------------------------------------------------
	#var file = FileAccess.open(json_path, FileAccess.READ) #Dummy email file
	#assert(file.file_exists(json_path), "File path does not exist")
	#var json = file.get_as_text()
	#var json_object = JSON.new()
	#json_object.parse(json)
	#emails = json_object.data
	#populate_unread_emails()
	#update_email_counters()

	var info = FileAccess.open(companyinfo_path, FileAccess.READ) #Dummy company info file 
	assert(info.file_exists(companyinfo_path), "File path does not exist")
	companyinfo = info.get_as_text()
	populate_company_info()
	
	var yourrole = FileAccess.open(yourrole_path, FileAccess.READ) #Dummy your role file
	assert(yourrole.file_exists(yourrole_path), "File path does not exist")
	role = yourrole.get_as_text()
	populate_yourrole()
#---------------------------------------------------------------------------------------------------


#-----Sample Data-----------------------------------------------------------------------------------
	
	#questions file
	var questions_file = FileAccess.open(questions_path, FileAccess.READ) #Questions.json
	assert(questions_file.file_exists(questions_path), "File path does not exist")
	var quest = questions_file.get_as_text()
	var quest_object = JSON.new()
	quest_object.parse(quest)
	emails = quest_object.data["questions"] #<--will likely need
	
	#debug because nothing wants to work (working now)
	#for i in emails.size():
		#var e = emails[i]
		#print("email at index %d:" % i, e)
		#print("emailonready")
		#print("has sender_id:", e.has("sender_id"))
		#print("value of sender_id:", e.get("sender_id", "MISSING"))

	for email in emails:
		email["read"] = false
		#print(email)
		#print(typeof(email))

	

	#dialogue-tree file
	var dialogue_file = FileAccess.open(dialogue_path, FileAccess.READ) #dialogue-tree.json
	assert(dialogue_file.file_exists(dialogue_path), "File path does not exist")
	var dialogue = dialogue_file.get_as_text()
	var dialogue_object = JSON.new()
	dialogue_object.parse(dialogue)
	
	#scenario file
	var scenario_file = FileAccess.open(scenario_path, FileAccess.READ) #Scenario.json
	assert(scenario_file.file_exists(scenario_path), "File path does not exist")
	var scen = scenario_file.get_as_text()
	var scen_object = JSON.new()
	scen_object.parse(scen)
	
	#senders file
	var senders_file = FileAccess.open(senders_path, FileAccess.READ) #Senders.json
	assert(senders_file.file_exists(senders_path), "File path does not exist")
	var send = senders_file.get_as_text()
	var senders_object = JSON.new()
	senders_object.parse(send)
	#print(typeof(senders_object.data))  
	#print(senders_object.data)          

	for sender in senders_object.data["senders"]:
		sender_lookup[int(sender["id"])] = sender["name"] #key value pairs
		
	#print("sender_lookup populated with:", sender_lookup) #this is correct
	
	populate_unread_emails() 
	update_email_counters() #this works yay!
	#---------------------------------------------------------------------------------------------------

func _process(_delta: float) -> void:
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

func get_sender_name(sender_id: int) -> String:
	
	if sender_id == null:
		print("sender_id null")
	else: 
		print("sender_id still good")
	 
	return sender_lookup.get(sender_id, "Unknown Sender")

func populate_unread_emails(): # will handle formatting mostly
	 
	for email in emails: #for each email that is inside of the emails array (runs for each email)
		var sid = email["sender_id"] #assigns the sender id of that email to sid
		var subject = email["subject"] #assigns the subject of the email to the subject variable
		if email == null: #if that email is null then
			print("email is null") #tell me that email is null
			continue
		if !email.has("sender_id") or !email.has("subject"): #if that same email does not have a sender id or it does not have a subject
			print("email missing required fields:", email) #tell me the missing pieces
			continue
		
		#-----This part allows me to fiddle with the formatting but as of now it breaks the read/unread portion. Leaving for now----------------------------
		#var sender_margin = MarginContainer.new()
		#sender_margin.add_theme_constant_override("margin_left", 10)
		#sender_margin.add_theme_constant_override("margin_top", 5)
		#var sender_label = Label.new()
		#sender_label.text = get_sender_name(sid)
		#sender_label.add_theme_font_size_override("font_size", 14)
		#email_container.add_child(sender_label)
		#sender_margin.add_child(sender_label)
		#email_container.add_child(sender_margin)

		#var subject_margin = MarginContainer.new()
		#subject_margin.add_theme_constant_override("margin_left", 10)
		#var subject_label = Label.new()
		#subject_label.text = email["subject"]
		#subject_label.add_theme_font_size_override("font_size", 10)
		#subject_margin.add_child(subject_label)
		#email_container.add_child(subject_margin)
		#--------------------------------------------------------------------------------------------------------------------------------------------------
		
		var email_container = VBoxContainer.new()
		var sender_label = Label.new() #Create a label for the vbox for the Sender
		sender_label.text = get_sender_name(sid) #populate it ***I think this line is the issue?***
		sender_label.add_theme_font_size_override("font_size", 14) #formatting
		sender_label.add_theme_constant_override("margin_left", 50) #formatting This line isn't working **because it isn't a margin container. Will fix
		email_container.add_child(sender_label) #adds the sender info the the email
		
		var subject_label = Label.new() #creates a new label called subject_name
		subject_label.text = subject #populates the text from the subject_label with the subject 
		subject_label.add_theme_font_size_override("font_size", 10)#formatting
		subject_label.add_theme_constant_override("margin_left", 50)#formatting Fix to margin container
		email_container.add_child(subject_label) #adds the subject to the email

		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(0, 50)
		panel.connect("gui_input", Callable(self, "_on_email_click").bind(email))
		panel.add_child(email_container)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		$Unread_Messages/Unread_Vbox.add_child(panel) 

func load_emails(): #will use to work though the dialogue tree and then send to populate

	#current_email = emails[index]
	#if scenario_id == 1: #allows for more scenarios in the future, currently shows scenario 1 (set 1 as default)
	#	for branch in branches:
	#		if branch ["from"] == current_node_id:
				#initialize the string variable here
				#if check
				#if correct: #T/F
					#current_node_id = branch["to"]	
						#move to next branch
		#-----Dialogue tree for email flow---------------------------------------------------------
		#for email in emails   gives all of the email options
		

			
		#get branches
		#what is from          check criteria for correctness for navigation to next to
		#if criteria correct
		#to
		#else to
		#increment scenario_id  Is this correct? Do we want to increment here or later? Not enough JSON info
		
		#else if                allows more questions in scenario 1
		#what is from           check criteria for correctness for navigation to next to
		#get branches
		#if criteria correct
		#to
		#else to
		#show to 
		#increment scenario id
		
		
		
		
		
		
		
		
		
		populate_unread_emails()

func populate_questions(): #populate the questions into the form
	pass

func load_questions(): #will load the questions per the dialogue tree
	pass

func _on_email_selected(email): #when an email is selected
	#pass
#-----Testing---------------------------------------------------------------------------------------	
	current_email = email
	var sid = email["sender_id"]

	var full_text = "[color=black][b]From:[/b] %s\n[b]Subject:[/b] %s\n\n%s[/color]" % [
		get_sender_name(sid), 
		email.subject,
		email.question
	]
	$Main_Message/Main_Area.bbcode_text = full_text

	if not email.read: 
		
		var email_container = VBoxContainer.new()
		
		var sender_margin = MarginContainer.new()
		sender_margin.add_theme_constant_override("margin_left", 10)
		sender_margin.add_theme_constant_override("margin_top", 5)
		var sender_label = Label.new()
		sender_label.text = get_sender_name(sid)
		sender_label.add_theme_font_size_override("font_size", 14)
		sender_margin.add_child(sender_label)
		email_container.add_child(sender_margin)

		var subject_margin = MarginContainer.new()
		subject_margin.add_theme_constant_override("margin_left", 10)
		var subject_label = Label.new()
		subject_label.text = email["subject"]
		subject_label.add_theme_font_size_override("font_size", 10)
		subject_margin.add_child(subject_label)
		email_container.add_child(subject_margin)
		
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(0, 50)
		panel.connect("gui_input", Callable(self, "_on_email_click").bind(email))
		panel.add_child(email_container)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP

		$Read_Messages/Read_Vbox.add_child(panel)

		for child in $Unread_Messages/Unread_Vbox.get_children():
			if child.get_child_count() > 0:
				var container = child.get_child(0)
				if container is VBoxContainer and container.get_child_count() > 1:
					var subject_check = container.get_child(1)
					if subject_check is Label and subject_check.text == email.subject:
						child.queue_free()
						break
	
	email.read = true
	update_email_counters()

func _on_email_click(event: InputEvent, email): #when the user clicks the emails
	if event is InputEventMouseButton and event.pressed:
		_on_email_selected(email)

func update_email_counters(): #handles the counters on the side panel
	var inbox_count = 0
	var sent_count = 0


#Keep this--------------------
	for email in emails:
		if email.get("answered", false):
			sent_count += 1
		else:
			inbox_count += 1
#-----------------------------
	#for email in emails:
		#print(email["subject"], " answered? ", email.get("answered", false))

	$Side_Panel/Inbox_Number.text = str(inbox_count)
	$Side_Panel/Sent_Items_Number.text = str(sent_count)

#-----Mostly handles panel switching between objects in the game-------------------------------------------

func _on_submit_button_pressed() -> void: #handles what happens when the user answers the emails **probably put attribute info here**
	$Response.visible = false
	$Answer.visible = false
	
	#current_email = email
	if current_email and not current_email.get("answered", false):
		current_email["answered"] = true
	
	#current_email = email
	#if current_email and not current_email["answered"]:
	#	current_email.answered = true

		var unread_box = $Unread_Messages/Unread_Vbox
		var read_box = $Read_Messages/Read_Vbox

		for box in [unread_box, read_box]:
			for child in box.get_children():
				if child.get_child_count() > 0:
					var container = child.get_child(0)
					if container is VBoxContainer and container.get_child_count() > 1:
						var subject_check = container.get_child(1)
						if subject_check is MarginContainer and subject_check.get_child_count() > 0: #check this one
							var subject_check_label = subject_check.get_child(0)
							if subject_check_label is Label and subject_check_label.text == current_email.subject:
								child.queue_free()
								break
		
		var email_container = VBoxContainer.new()
		
		var sender_label = Label.new() #Create a label for the vbox for the Sender
		sender_label.text = get_sender_name(current_email["sender_id"]) #populate it ***I think this line is the issue?***
		sender_label.add_theme_font_size_override("font_size", 14) #formatting
		sender_label.add_theme_constant_override("margin_left", 50) #formatting This line isn't working **because it isn't a margin container. Will fix
		email_container.add_child(sender_label) #adds the sender info the the email
		
		var subject_label = Label.new() #creates a new label called subject_name
		subject_label.text = current_email["subject"] #populates the text from the subject_label with the subject 
		subject_label.add_theme_font_size_override("font_size", 10)#formatting
		subject_label.add_theme_constant_override("margin_left", 50)#formatting Fix to margin container
		email_container.add_child(subject_label) #adds the subject to the email

		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(0, 50)
		panel.connect("gui_input", Callable(self, "_on_email_click").bind(current_email))
		panel.add_child(email_container)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		$Sent_Items/Sent_Vbox.add_child(panel) 
		
		
		#var email_container = VBoxContainer.new()
		#var subject = email["subject"] 
		#var sender_label = Label.new() 
		#sender_label.text = get_sender_name(sid)
		#sender_label.add_theme_font_size_override("font_size", 14)
		#sender_label.add_theme_constant_override("margin_left", 10)
		#email_container.add_child(sender_label) 

		#var subject_margin = MarginContainer.new()
		#subject_margin.add_theme_constant_override("margin_left", 10)
		#var subject_label = Label.new()
		#subject_label.text = current_email.subject
		#subject_label.add_theme_font_size_override("font_size", 10)
		#subject_margin.add_child(subject_label)
		#email_container.add_child(subject_margin)
		
		#var panel = Panel.new()
		#panel.custom_minimum_size = Vector2(0, 50)
		#panel.connect("gui_input", Callable(self, "_on_email_click").bind(email))
		#panel.add_child(email_container)
		#panel.mouse_filter = Control.MOUSE_FILTER_STOP

		#$Read_Messages/Read_Vbox.add_child(panel)

		for child in $Unread_Messages/Unread_Vbox.get_children():
			if child.get_child_count() > 0:
				var container = child.get_child(0)
				if container is VBoxContainer and container.get_child_count() > 1:
					var subject_check = container.get_child(1)
					if subject_check is Label and subject_check.text == current_email.subject:
						child.queue_free()
						break
	
		
		#var email_container = VBoxContainer.new()

		#var sender_margin = MarginContainer.new()
		#sender_margin.add_theme_constant_override("margin_left", 10)
		#var sender_label = Label.new()
		#sender_label.text = current_email.sender
		#sender_label.add_theme_font_size_override("font_size", 14)
		#sender_margin.add_child(sender_label)
		#email_container.add_child(sender_margin)

		#var subject_margin = MarginContainer.new()
		#subject_margin.add_theme_constant_override("margin_left", 10)
		#var subject_label = Label.new()
		#subject_label.text = current_email.subject
		#subject_margin.add_child(subject_label)
		#email_container.add_child(subject_margin)

		#var panel = Panel.new()
		#panel.custom_minimum_size = Vector2(0, 50)
		#panel.add_child(email_container)
		#panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

		$Sent_Items/Sent_Vbox.add_child(panel)
		#print("Marking answered:", current_email["subject"])

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
