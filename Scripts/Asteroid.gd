class_name Asteroid extends Node3D

var asteroid_scene = preload("res://Entities/Asteroid.tscn")
var script_to_attach = preload("res://Scripts/Asteroid.gd") # Use `load()` if you don't want to preload

@export var asteroid_type = "stone"
var asteroid_state = 3
var ore_amount = 0
var update_flag = false

@onready var collider = %CollisionShape3D
@onready var model = $Icosphere

func _ready():
	ore_amount = randf_range(10, 25)
	asteroid_state = 3
	update_flag = true

func _process(delta):
	#If we have newer information, update it.
	#Flag allows us to save performance by only updating when we have new info
	if update_flag:
		update_scale()
		get_parent_node_3d().mass = asteroid_state * asteroid_state * asteroid_state
		
		update_flag = false
		
func update_scale():
	match(asteroid_state):
		1:
			model.scale = Vector3(1, 1, 1)
			collider.scale = Vector3(1, 1, 1)
		2:
			model.scale = Vector3(3, 3, 3)
			collider.scale = Vector3(3, 3, 3)
		3:
			model.scale = Vector3(5, 5, 5)
			collider.scale = Vector3(5, 5, 5)
		_:
			print("Bro what?")
			
func split():
	if asteroid_state == 1: 
		return

	for i in range(10):
		# Instance the loaded asteroid scene.
		var new_asteroid_instance = asteroid_scene.instantiate()

		if new_asteroid_instance:
			get_tree().root.add_child(new_asteroid_instance)
			# Ensure the node is ready and its children are accessible, if necessary.
			await(new_asteroid_instance.is_node_ready())
			
			# Now that new_asteroid_instance is ready, access its ScriptNode
			var child = (new_asteroid_instance.get_node("ScriptNode") if new_asteroid_instance.has_node("ScriptNode") else null)
			child.script = script_to_attach
			
			if child:
				var pos = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
				var vel = pos.normalized()
				new_asteroid_instance.global_transform.origin = pos + self.global_transform.origin
				new_asteroid_instance.linear_velocity = vel*3
				child.asteroid_type = self.asteroid_type
				child.asteroid_state = self.asteroid_state
				child.ore_amount = self.ore_amount
				child.update_flag = true  # Ensure the asteroid updates itself
			else:
				print("ScriptNode not found in the new asteroid instance.")
				
	# Remove the original asteroid.
	get_parent_node_3d().queue_free()

