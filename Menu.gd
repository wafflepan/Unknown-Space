extends Control

func getPromptData():
	var results = {}
	for prompt in $Prompts.get_children():
		var promptname = prompt.get_child(1).name
		results[promptname] = prompt.get_child(1).text
	return results

func _on_CreateServer_pressed():
	print("Server created with following data:", getPromptData())
	NetworkManager.createServer(getPromptData())
#	get_tree().change_scene("res://GameWorld.tscn")


func _on_JoinServer_pressed():
	print("Server joined with following data:", getPromptData())
	NetworkManager.joinServer(getPromptData())
#	get_tree().change_scene("res://GameWorld.tscn")
