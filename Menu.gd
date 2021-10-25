extends Control

func _ready():
	NetworkManager.connect("update_connected_players",self,"updateConnectedPlayers")
	$ServerConfirm.connect("confirmed",self,"serverStartButton")
	$ServerConfirm.add_button("Cancel",true,"cancel_server")
	$ServerConfirm.connect("custom_action",self,"serverconfirm_button")

func getPromptData():
	var results = {}
	for prompt in $Prompts.get_children():
		var promptname = prompt.get_child(1).name
		results[promptname] = prompt.get_child(1).text
	return results

func _on_CreateServer_pressed():
	print("Server created with following data:", getPromptData())
	NetworkManager.createServer(getPromptData())
	activateLobby()


func _on_JoinServer_pressed():
	print("Server joined with following data:", getPromptData())
	NetworkManager.joinServer(getPromptData())
	activateWait()

func activateWait():
	$ConfirmationDialog.popup_centered()
	updateConnectedPlayers()

func activateLobby():
	$ServerConfirm.popup_centered()
	updateConnectedPlayers()

func updateConnectedPlayers():
	print("updateconnectedplayers: ",NetworkManager.players)
	var players = NetworkManager.players
	var playerlist = str("")
	for player in players:
		playerlist = playerlist + '\n' + players[player]["Username"]+(" (Host)" if player==1 else "")
	$ServerConfirm.dialog_text = str(players.size(),"/",NetworkManager.MAX_PLAYERS," Connected:\n",playerlist)

func isLobbyActive():
	pass
	return $ServerConfirm.visible

func serverStartButton():
	rpc("serverStartCommand") #This should only ever be visible as a button for the server start. TODO: Add a check

func serverconfirm_button(action):
#	print("action: ",action)
	if action == "cancel_server":
		terminateConnection()
		$ServerConfirm.visible=false

remotesync func serverStartCommand():
	NetworkManager.disconnect("update_connected_players",self,"updateConnectedPlayers") #Disconnect signals before switching scenes, might not be needed?
	get_tree().change_scene("res://GameWorld.tscn") #Notify everybody to start the game.

func _on_ConfirmationDialog_custom_action(action):
	print(action)

func terminateConnection():
	pass
	NetworkManager.terminateConnection()
