extends MultiplayerSpawner

@export var asteroid_scene = preload("res://Entities/Asteroid.tscn")
@export var asteroid_script = preload("res://Scripts/Asteroid.gd") # Use `load()` if you don't want to preload

# Called when the node enters the scene tree for the first time.
func _ready():
	set_spawn_function(Callable(self, "custom_spawn"))
	
func custom_spawn(data):
	var pos = data[0]
	var type = data[1]
	var state = data[2]
	var ore = data[3]
	var id = "asteroid_" + str(data[4])
	var flags = data[5]
	
	var new_asteroid_instance : Node3D = asteroid_scene.instantiate()
	if new_asteroid_instance:
		var child = (new_asteroid_instance.get_node("ScriptNode") if new_asteroid_instance.has_node("ScriptNode") else null)
		child.script = asteroid_script
		
		if child:
			new_asteroid_instance.name = id
			new_asteroid_instance.position = pos
			new_asteroid_instance.angular_velocity = flags["ang"] if flags.has("ang") else Vector3.ZERO 
			new_asteroid_instance.linear_velocity = flags["lin"] if flags.has("lin") else Vector3.ZERO 
			child.asteroid_type = type
			child.asteroid_state = state
			child.ore_amount = ore
			child.asteroid_ore = flags["ore"] if flags.has("ore") else "Stone"
			child.update_flag = true  # Ensure the asteroid updates itself
		else:
			print("ScriptNode not found in the new asteroid instance.")
	return new_asteroid_instance

func _on_spawned(node):
	pass
