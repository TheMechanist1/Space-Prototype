class_name Activatable extends Node3D

func activate() -> void:
	print("Activated")

@rpc("any_peer")
func activate_rpc():
	activate()
