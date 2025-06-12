extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Unread_Messages.visible = false
	$Read_Messages.visible = true
	$Response.visible = false
	$Answer.visible = false
	$Read_Messages.visible = true
	$Unread_Messages.visible = false
	$Read_Unread.visible = true
	$Sent_Items.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_exit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_read_unread_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$Unread_Messages.visible = true
		$Read_Messages.visible = false
	else:
		$Unread_Messages.visible = false
		$Read_Messages.visible = true
		
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
	$Read_Messages.visible = false
	$Unread_Messages.visible = false
	$Read_Unread.visible = false
	pass # Replace with function body.


func _on_inbox_button_pressed() -> void:
	$Read_Messages.visible = true
	$Unread_Messages.visible = false
	$Read_Unread.visible  = true
	$Sent_Items.visible = false
	pass # Replace with function body.
