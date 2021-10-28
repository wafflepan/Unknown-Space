extends Panel

var players:Dictionary = {} setget onDictUpdated
var self_info = {}

var DEFAULT_MOTD = "Welcome to Unknown Space!"

onready var chat:RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel
onready var input:LineEdit = $MarginContainer/VBoxContainer/LineEdit

func onDictUpdated(newval):
	pass
#	print("PLAYERDICTCHANGED: ",players,"  ",newval)

func _ready():
	NetworkManager.connect("newplayerconnected",self,"playerConnectNotify")
	NetworkManager.connect("playerdisconnected",self,"playerDisconnectNotify")
	chat.bbcode_text=""
	syncPlayers()
	self_info=players[multiplayer.get_network_unique_id()]
	if multiplayer.is_network_server():
#		startChat() #Only the host needs to set up the initial chat conditions, everyone else just gets passed the updates.
		rpc("updateChat",startChatMessages())

func syncPlayers():
	players=NetworkManager.NETWORK_players
	print("NetworkChat ",multiplayer.get_network_unique_id()," Synchronized Playerlist with NetworkManager:")
	print("Players: ",players)

func submitLine(text):
	var message = text+'\n'
	rpc("updateChat",message)

remotesync func updateChat(addition):
	chat.bbcode_text += addition

func startChatMessages():
	var result = ""
	result = (str("Serverchat Started at ",OS.get_unix_time(),"\n"))
	result += getMOTD()
	return result

func getMOTD():
	return (DEFAULT_MOTD + '\n')

const COMMAND_CHARACTER = '/'

func checkForCommands(input:String): #Parses server commands from the chat box if they're prefixed with '/'
	pass
	if input.begins_with(COMMAND_CHARACTER):
		var raw = input.trim_prefix(COMMAND_CHARACTER)
		var all = raw.rsplit(" ",false)
		var command = all[all.size()-1] #The first word before spaces is the primary command
		var args = all
		args.remove(args.size()-1)
		print("Attempting to execute command '",command,"' with arguments: ",args)
		match command:
			"quit":
				NetworkManager._server_disconnected()
			"kick":
				for username in args:
					pass #Find player ID via username, and forcibly disconnect them.
#					get_tree().network_peer.disconnect_peer(id)
				pass
		return true
	else:
		return false

func _on_LineEdit_text_entered(new_text):
	if checkForCommands(new_text):
		return #Don't bother displaying commands into the chat
	var fulltext:String = str('[color=#',Color(self_info["Username"].hash()).to_html().left(6),'][',self_info["Username"],'][/color]: ',new_text)
	submitLine(fulltext)
	input.clear()

func _unhandled_input(event): #Click-deselection of the textbox to allow for character input again
	if event is InputEventMouseButton and get_focus_owner() == input:
		input.release_focus()

func getTimestamp():
	pass #Return a local UTC timestamp for hours-minutes to date chatlog lines

func playerConnectNotify(id, _info):
	print("ConnectNotify")
	syncPlayers()
	submitLine(str("[SERVER]: Player '",players[id]["Username"],"' has joined the server."))

func playerDisconnectNotify(id):
	print("DisconnectNotify")
	print("Players at point of Disconnect: ",players)
	submitLine(str("[SERVER]: Player '",players[id]["Username"],"' disconnected from server."))
	syncPlayers()

func _on_LineEdit_gui_input(event):
	if event is InputEventKey:
		get_tree().set_input_as_handled() #While selected, block all input elsehwere to prevent character motion
#		print("lineedit ate input")

func sendNotification(notification): #A private message that gives feedback on an action.
	updateChat(notification+'\n')
