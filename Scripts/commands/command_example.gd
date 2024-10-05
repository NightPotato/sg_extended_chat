extends Node

# This is the method that will be called when the dynamic command is executed.
# The 'args' parameter will contain any arguments passed to the command.
func execute(args: Array):
    if args.size() > 0:
        var effect_strength = float(args[0])  # Assuming the first argument is the strength of the fire effect
        
    else:
        print("[color=#FEE761][ExtendedChat] Usage: /fire [strength][/color]")
        ECAPI.send_message_locally("[color=#FEE761][ExtendedChat] Usage: /fire [strength][/color]")

