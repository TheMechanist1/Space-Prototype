class_name Activatable extends Node3D

func activate(type) -> void:
	print("Activated")

@rpc("any_peer")
func activate_rpc(type):
	print(type)
	activate(type)
