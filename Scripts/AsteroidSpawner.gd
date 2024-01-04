extends Node3D

@export var asteroid_scene = preload("res://Entities/Asteroid.tscn")
@export var asteroid_script = preload("res://Scripts/Asteroid.gd") # Use `load()` if you don't want to preload
var spawner

# Here we have a list of all the asteroids and there ids
# The server retains a list of all of these and when an asteroid is changed in some way, this list will be updated and the server will notify the clients with the new list
# The clients will then Recive the update request and add/modify/delete the asteroid from the local scene
# CONSIDERATIONS AND POSSIBLE ISSUES
# Ideally only send newly updated asteroids to minimize network load
# If two players update the same asteroid at the same time, there might be issues
var Asteroids = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func inital_setup():
		print("Multiplayer setup:" + str(multiplayer.get_unique_id()))
		
		for i in range(250):
			var initial_properties = {
				pos = Utility.random_vector3_exclusion(Vector3(-500, -500, -500), Vector3(500, 500, 500), Vector3(-100, -100, -100), Vector3(100, 100, 100)),
				asteroid_type = "stone",
				asteroid_state = randi_range(1, 3),
				ore_amount = 0,
				angular = Utility.random_vector3(Vector3(-5, -5, -5), Vector3(5, 5, 5)),
				linear = Utility.random_vector3(Vector3(-5, -5, -5), Vector3(5, 5, 5))
			}
			create_asteroid(initial_properties)
		
func create_asteroid(asteroid_properties):
	if(!asteroid_properties): return
	spawner = get_tree().current_scene.get_node("AsteroidMultiSpawner")
	spawner.spawn([
			asteroid_properties.pos,
			asteroid_properties.asteroid_type,
			asteroid_properties.asteroid_state,
			asteroid_properties.ore_amount,
			Asteroids.size()+1,
			asteroid_properties.angular,
			asteroid_properties.linear
		])
	
func remove_asteroid(name):
	var asteroid = get_tree().current_scene.get_node(NodePath(name))
	asteroid.queue_free()
	
@rpc("any_peer")
func create_asteroid_rpc(asteroid_properties):
	create_asteroid(asteroid_properties)
	
@rpc("any_peer")
func remove_asteroid_rpc(asteroid):
	remove_asteroid(asteroid)
	
#@rpc("any_peer")
#func init_asteroids_rpc():
#	inital_setup()
	
#@rpc("any_peer")
#func update_asteroid_list_rpc(new_list):
#	update_asteroid_list(new_list)
	
