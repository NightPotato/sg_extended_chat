extends LineEdit

var ecapi: EC_API = null

func _ready():
    # Ensure ECAPI is instantiated properly
	ecapi = get_node("/root/ModAPI/pd_extended_chat/ECAPI")  # Adjust path if needed based on your scene tree

# Extended OnTextSubmited Event to Check for / as first char.
func _on_text_submitted(new_text: String):
	if text.replace(" ", "").length() > 0:
		if ecapi == null:
			ecapi = get_node("/root/ModAPI/pd_extended_chat/ECAPI")
			_send_local_message("[color=#FEE761][ExtendedChat] Error: ECAPI is Null.[/color]")

		if new_text.begins_with("/"):
			_parse_command(new_text)
		else:
			get_node("/root/Multiplayer").send_chatbox_message.rpc(owner.owner.username, new_text)
	text = ""
	release_focus()


func force_submit():
	print(self)
	_on_text_submitted(text)


func _process(_delta):
	if !Global.controllerActive:
		if has_focus():
			owner.currentInactivityTime = owner.inactivityTime
		elif is_instance_valid(Global.activePlayer):
			Global.activePlayer.chatSelected = false


func _on_focus_entered():
	if !Global.controllerActive:
		Global.activePlayer.canInteract = false
		Global.activePlayer.canMove = false
		Global.activePlayer.chatSelected = true


func _on_focus_exited():
	if !Global.controllerActive:
		Global.activePlayer.canInteract = true
		Global.activePlayer.canMove = true


#
# Modified Logic is Below
#	DO NOT MODIFY BELOW THIS POINT OR COMMAND WILL NOT WORK.
#

# Function to add Local Messages to Chat that are not sent to everyone
func _send_local_message(output_text):
	if is_instance_valid(Global.activePlayer):
		var chatbox = Global.activePlayer.get_node("Canvas/ChatBox")
		var messageBox = chatbox.get_node("MarginContainer/VBoxContainer/Messages")
		messageBox.pop_all()
		messageBox.append_text(output_text + "\n")
		messageBox.pop_all()

func _parse_command(command_text: String):
	var parts = command_text.split(" ")  # Split command into parts
	var command = parts[0]  # The first part is the command
	
	# Check if the command exists in ECAPI's commandHandlers
	if command in ecapi.commandHandlers:
		_execute_command(command, parts.slice(1))  # Handle the command
	else:
		_send_local_message("[color=#FEE761][ExtendedChat] Unknown command: " + command + "[/color]")

# Function to handle both built-in and dynamic commands
func _execute_command(command: String, args: Array):
	var command_entry = ecapi.commandHandlers[command]
	var handler = command_entry.get("CommandHandler", "")
	
	# Check if it's a built-in handler or a script file
	if handler.begins_with("builtin_"):  # Handle built-in commands
		match handler:
			"builtin_help_handler":
				handle_help(args)
			"builtin_say_handler":
				handle_say(args)
			"builtin_give_handler":
				handle_give(args)
			"builtin_minespeed_handler":
				handle_setMineSpeed(args)
			_:
				_send_local_message("[color=#FEE761][ExtendedChat] Error: Built-in command not found.[/color]")
	else:  # Handle external script-based commands
		var script = load(handler)
		if script:
			var instance = script.new()
			if instance and instance.has_method("execute"):
				instance.execute(args)
				_send_local_message("[color=#FEE761][ExtendedChat] Executed dynamic command: " + command + "[/color]")
			else:
				_send_local_message("[color=#FEE761][ExtendedChat] Error: Dynamic command script missing 'execute' method![/color]")
		else:
			_send_local_message("[color=#FEE761][ExtendedChat] Error: Failed to load dynamic command script.[/color]")


#
# Built-In Commands Handlers
#

# TODO: Extend the Help Command to handle /help [commandName] which will return a Usage from the CommandHandler Definition
func handle_help(args: Array):
	if args.size() > 0:
		var message = String(" ").join(args)  # Correct usage of join
		print("[color=#FEE761][ExtendedChat] - Recieved Help Command with Args: " + message + "[/color]")
	var available_commands = String(", ").join(ecapi.commandHandlers.keys())  # Correct usage of join
	_send_local_message("[color=#FEE761][ExtendedChat] - Available commands: " + available_commands + "[/color]")

func handle_say(args: Array):
	if args.size() > 0:
		var message = String(" ").join(args)  # Correct usage of join
		_send_local_message(message)
	else:
		_send_local_message("[color=#FEE761][ExtendedChat] - Usage: /say [message][/color]")

# TODO: Support Multiplayer within the Give Command
func handle_give(args: Array):
	if args.size() > 0:
		print(Global.activePlayer)
		var root = get_node("/root/Multiplayer")

		var actual_give_alert = "[color=#FEE761][ExtendedChat] - Gave yourself {amount}x{item_id}! You are a cheater :D[/color]".format({
			"amount": args[1],
			"item_id": args[0]
		})

		# var itemToGive = Global.create_item_dict("starground:coal", 2)
		var itemToGive = Global.create_item_dict(args[0], int(args[1]))
		root.create_item(itemToGive, Global.activePlayer.global_position, 50)
		_send_local_message(actual_give_alert)

	else:
		_send_local_message("[color=#FEE761][ExtendedChat] - Usage: /give [item_id] [amount][/color]")
		_send_local_message("[color=#FEE761][ExtendedChat] - Currently only giving items to inventory not supported yet! Items will spawn on the ground near you![/color]")


func handle_setMineSpeed(args: Array):
	if args.size() > 0:
		var player = Global.activePlayer
		player.miningTime = float(args[0])
		_send_local_message("[color=#FEE761][ExtendedChat] - You have set your Mining Speed![/color]")
	else:
		_send_local_message("[color=#FEE761][ExtendedChat] - Usage: /setrange [range] (Default Range:128)[/color]")
