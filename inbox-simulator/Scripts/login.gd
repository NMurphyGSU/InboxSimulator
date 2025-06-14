# Author: Michael Knighten
# Date: 6/13/2025
#
# Descritption:
# This script handles the entire login scene and saves account information
#
# JSON save location: Owner>AppData>Roaming>Godot>app_userdata>Inbox Simulator>Data
#
# Notes:
# -Currently creates account data but not attributes(Add attributes later)
# -When login is successful it will put you into the self assessment scene
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

const SAVE_PATH := "user://Data/User_Data.json"
var user_data := {}
var character_limit: int = 8

#----------------------------------
func _ready():
	
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

	create_new_user(username, password)
	account_message_label.text = "Account created! Proceeding..."
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
func create_new_user(username: String, password: String):
	user_data[username] = {
		"password": password,
		"attributes": {}
	}
	save_user_data()

#----------------------------------
func _change_scene():
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
