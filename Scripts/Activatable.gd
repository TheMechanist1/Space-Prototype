class_name Activatable extends Node3D

func get_node_from_type(type):
	return get_tree().root.get_node(NodePath(str(type["node_path"])))
	
func activate(type) -> void:
	print("Activated")

@rpc("any_peer")
func activate_rpc(type):
	print(type)
	activate(type)
