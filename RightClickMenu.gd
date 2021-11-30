extends PopupMenu

func _ready():
	set_process_input(false)

func loadOptions(optionsdict):
	pass

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		print("Cleared")
		self.rect_position = get_global_mouse_position()
#		self.visible=false

func _on_RightClickMenu_about_to_show():
	print("Right click menu opened")
	set_process_input(true)

func _on_RightClickMenu_popup_hide():
	set_process_input(false)
