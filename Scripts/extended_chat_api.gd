class_name EC_API extends Node

var commandHandlers: Dictionary = {
	"/help": {
		"CommandHandler": "builtin_help_handler",
		"CommandUsage": "This should never be shown. If it is, please report it!"
	},
	"/give": {
		"CommandHandler": "builtin_give_handler",
		"CommandUsage": "/give [item_id] [amount]"
	},
	"/minespeed": {
		"CommandHandler": "builtin_minespeed_handler",
		"CommandUsage": "/minespeed [float_value] | Lower = Faster"
	}
}

#
# Add a Command to the CommandHandlers | commandKey = "/command"
#   commandHandler | "res://Scripts/command.gd"
#   commandUsage   | String that explains how to use your command since auto-complete is not yet possible.
#
func add_command(commandKey: String, commandHandler:String, commandUsage: String):
	var entry: Dictionary = {
		commandKey: {
			"CommandHandler": commandHandler,
			"CommandUsage": commandUsage
		}
	}
	commandHandlers.merge(entry)

#
#	Remove a Command from the CommandHandlers | commandKey = "/command"
#
func remove_command(commandKey: String):
	commandHandlers.erase(commandKey)

#
# Helper Method to Input Text to Console with out a RPC beign triggered, Client-Side Messages.
#
static func send_message_locally(message: String):
	var chatbox = Global.activePlayer.get_node("Canvas/ChatBox")
	var messageBox = chatbox.get_node("MarginContainer/VBoxContainer/Messages")
	messageBox.pop_all()
	messageBox.append_text(message + "\n")
	messageBox.pop_all()
