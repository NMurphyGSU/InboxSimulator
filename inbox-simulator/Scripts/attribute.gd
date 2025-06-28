# Author: Michael Knighten
# Date: 6/19/2025
# Last Modified: 6/27/2025
#
# Descritption:
# This is simply put an object that is meant to be compiled into a list dependent on the number of attributes under a username in a JSON.
# It handles manual input of the value the user believes they should have in a specified attribute.
#
#
# Notes:
#
# Added: 6/19-21/2025
# -Systems that handle the naming, value, and input fields
# -Issue noted: issue where the scroll wheel can manipulate the slider while scrolling(Not Fixed)
#
# Added 6/27/2025
# -Fixed getters
# !!!SCRIPT IS COMPLETE FOR PROTOTYPE!!!

extends Control

@onready var name_label = $Label_Attribute
@onready var attribute_slider = $HSlider_Attribute
@onready var attribute_label = $Label_Value

func _ready():
	attribute_slider.value_changed.connect(_on_slider_value_changed)
	_on_slider_value_changed(attribute_slider.value)

func _on_slider_value_changed(value):
	attribute_label.text = str(round(value))

func set_display_name(text: String):
	name_label.text = text

# Manu
func set_value(value: float):
	attribute_slider.value = value

func get_value() -> float:
	return attribute_slider.value

func get_display_name() -> String:
	return name_label.text
