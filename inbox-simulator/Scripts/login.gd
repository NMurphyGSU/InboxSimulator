# Author: Michael Knighten
# Date: 6/13/2025
# Last Modified: 6/20/2025
#
# Descritption:
# This script handles the entire login scene and saves/accesses account information
#
# JSON save location: Owner>AppData>Roaming>Godot>app_userdata>Inbox Simulator>Data
#
# Notes:
#
# Added: 6/13/2025
# -Currently creates account data but not attributes
# -When login is successful it will put you into the self assessment scene
# -Reads attributes from a text file and initializes them in the JSON
#
# Added: 6/19-20/2025
# -Holds the login username so it can access that specific account information via Singleton.gd
# -Attributes are read from a text file in the "Attributes" folder and then written to the JSON
# -Capital letter after attributes does not mean anything, was done to prevent shadowing since my naming scemes are lack luster
# !!!SCRIPT IS COMPLETE FOR PROTOTYPE!!!
#----------------------------------

#----------------------------------
extends Control

@export var username_input: LineEdit
@export var password_input: LineEdit
@export var username_error_label: Label
@export var password_error_label: Label
@export var account_message_label: Label
@export var login_button: Button
@export var create_button: Button
@export var next_scene: PackedScene  # Drag your next scene resource here

const SAVE_PATH := "user://Data/User_Data.json" # Writable
var user_data := {}
var character_limit: int = 8
var ATTRIBUTE_PATH := "res://Attributes/attributes.txt" # Not writable (Godot runtime restriction)
var attributes : String = ""

#----------------------------------
func _ready():
	
	attributes = write_attributes()
	
	load_user_data()
	
	login_button.disabled = true
	create_button.disabled = true

	username_input.text_changed.connect(_on_username_input_changed)
	password_input.text_changed.connect(_on_password_input_changed)
	
	login_button.pressed.connect(_on_LoginButton_pressed)
	create_button.pressed.connect(_on_CreateButton_pressed)
	
	username_error_label.add_theme_color_override("font_color", Color.RED)
	password_error_label.add_theme_color_override("font_color", Color.RED)
	account_message_label.add_theme_color_override("font_color", Color.RED)

#----------------------------------
func load_user_data():
	user_data = {}
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var result = JSON.parse_string(content)
			if typeof(result) == TYPE_DICTIONARY:
				user_data = result
			else:
				print("Failed to parse JSON.")
		else:
			print("Failed to open file.")
	else:
		print("Save file not found. Starting with empty user data.")

#----------------------------------
func save_user_data():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("Data"):
		var err = dir.make_dir("Data")
		if err != OK:
			push_error("Failed to create directory 'user://Data'")
			return

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json = JSON.stringify(user_data)
		file.store_string(json)
		file.close()

#----------------------------------
func _on_username_input_changed(new_text: String):
	var username = new_text.strip_edges()
	if username.length() < 4:
		username_error_label.text = "Username must be at least 4 characters."
	else:
		username_error_label.text = ""
	_check_login_ready()

#----------------------------------
func _on_password_input_changed(new_text: String):
	var password = new_text.strip_edges()
	if not is_valid_password(password):
		password_error_label.text = "Password must be 8+ chars, include a letter, number, and symbol."
	else:
		password_error_label.text = ""
	_check_login_ready()

#----------------------------------
func _check_login_ready():
	var username_ok = username_error_label.text == ""
	var password_ok = password_error_label.text == ""
	login_button.disabled = not (username_ok and password_ok)
	create_button.disabled = not (username_ok and password_ok)

#----------------------------------
func _on_LoginButton_pressed():
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()

	if user_data.has(username) and user_data[username]["password"] == password:
		Hold_Username_Logged_In(username)# Save the username
		_change_scene()
	else:
		account_message_label.text = "Account not found or wrong password. Please create an account."

#----------------------------------
func _on_CreateButton_pressed():
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()

	if user_data.has(username):
		account_message_label.text = "An account with this username already exists."
		return

	if not is_valid_password(password):
		account_message_label.text = "Invalid password. Please follow the rules."
		return

	create_new_user(username, password, attributes)
	account_message_label.text = "Account created! Proceeding..."
	Hold_Username_Logged_In(username)# Save the username
	_change_scene()


#----------------------------------
func is_valid_password(password: String) -> bool:
	if password.length() < character_limit:
		return false

	var has_letter := RegEx.new()
	has_letter.compile("[A-Za-z]")
	if not has_letter.search(password):
		return false

	var has_number := RegEx.new()
	has_number.compile("[0-9]")
	if not has_number.search(password):
		return false

	var has_symbol := RegEx.new()
	has_symbol.compile("[!@#\\$%\\^&*()_+\\-=\\[\\]{};:'\",.<>?/\\\\|]")
	if not has_symbol.search(password):
		return false

	return true

#----------------------------------
func create_new_user(username: String, password: String, attributesR: String):
	user_data[username] = {
		"password": password,
		"attributes Self": attributesR,
		"attributes Eval": attributesR
	}
	save_user_data()

#----------------------------------
func _change_scene():
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
		
#----------------------------------
func load_attributes(path: String) -> Array:
	var attributesK = []
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line != "":
				attributesK.append(line)
		file.close()
	else:
		push_error("Failed to open attributes file: " + path)
	return attributesK
#----------------------------------
func write_attributes():
	var attributesW = load_attributes(ATTRIBUTE_PATH)
	var attribute_list: String = ""
	for attributeN in attributesW:
		attribute_list += " %s:%d/" % [attributeN, 0]
	return attribute_list
#----------------------------------
func Hold_Username_Logged_In(used_username: String):# This is what holds the logged in users name for read/write access throughout the application.
	print(used_username + " is now keyed as the active user.")
	# Save username to global variable (Singleton)
	Singleton.Current_Username = used_username
	print(Singleton.Current_Username + " is saved as the key")
