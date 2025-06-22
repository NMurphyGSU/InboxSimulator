# Author: Michael Knighten
# Date: 6/21/2025
# Last Modified: 6/21/2025
#
# Descritption:
# Self Assessment scene, handles the slider attribute objects listing so players can self evaluate at their own preference.
# When they are satisfied, the results are then stored under their accounts self attributes for later comparison.
#
# Notes:
#
# Added: 6/21/2025
# -Added the vertical scroller box and object spawner.
# -Added the ability to use the Singleton to find the exact user for modification of their self attributes.
# -Added the ability for changes to be saved.
# -Fixed issue with offset during stacking of the attribute objects.
# -Fixed a spacing and alignment issue.
# -It correctly applies the correct number of attribute boxes based on the number of parced attributes read from the Users JSON entry
# -The names are correctly applied to each object
# -Now based on the changes the use makes, they will need to press "Proceed" to record the attribute vales and move to the next scene. Lol... Deltarune reference.(In progress)
# -Added the Label for "The purpose of the assessment...." and the title: "Pre-Assessment"

extends Node

@onready var control := $ScrollContainer/Control
var attribute_box_scene := preload("res://Objects/attribute_object.tscn")
var current_username = Singleton.Current_Username
var json_path = "user://Data/User_Data.json"
var recorded_data
var number_of_attributes

func _ready():
	populate_attributes(Count_JSON_attributes())
	apply_attributes_to_objects(recorded_data, number_of_attributes)

func Count_JSON_attributes():
	var file = FileAccess.open(json_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var err = json.parse(json_text)  # <-- Parse the JSON string first
	var data = json.get_data()       # <-- Now get the data after parsing
	
	print(data)
	print("Current user:", current_username)

	var attr_str = data[current_username].get("attributes Self", "")
	recorded_data=attr_str
	var parts = attr_str.split("/")
	var filtered_parts = []
	for s in parts:
		if s.strip_edges() != "":
			filtered_parts.append(s)
	parts = filtered_parts

	print("Number of attributes:", parts.size())
	number_of_attributes = parts.size()
	return parts.size()

func apply_attributes_to_objects(att: String, size: int):
	var attributes_array = []

	# Split by "/" to separate each attribute pair, e.g. " health:0"
	var parts = att.split("/")
	
	for part in parts:
		var trimmed = part.strip_edges()  # remove spaces
		if trimmed == "":
			continue  # skip empty
		
		# Each part looks like "health:0"
		# Split by ":" and take the attribute name (before ":")
		var attr_name = trimmed.split(":")[0]
		attributes_array.append(attr_name)
	
	# If you want to ensure the array is exactly 'size' length, you can:
	if attributes_array.size() > size:
		attributes_array = attributes_array.slice(0, size)
	# 2) or fill with empty strings if too short:
	while attributes_array.size() < size:
		attributes_array.append("")
		
	var att_list: String = "Attribute list: "
	for att_name in attributes_array:
		att_list += (att_name + " ")
	print(att_list)
	
	# go through the number of attribute objects and apply the name to them:
	var index := 0
	for child in control.get_children():
		if index >= attributes_array.size():
			break  # Avoid out-of-bounds errors
		child.set_display_name(attributes_array[index])
		index += 1


func populate_attributes(count: int) -> void:
	for child in control.get_children():
		child.queue_free()

	var offset := 100  # 100 units between each box vertically

	for i in range(count):
		var box = attribute_box_scene.instantiate()
		box.name = "AttributeBox_%d" % i
		control.add_child(box)

		# Manual vertical offset
		box.position = Vector2(0, i * offset)
		
	# Adjust container size to fit children
	control.custom_minimum_size.y = count * offset
