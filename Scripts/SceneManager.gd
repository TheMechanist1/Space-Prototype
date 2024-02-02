extends Node3D

@export var player_scene : PackedScene

# Here we have a list of all the asteroids and there ids
# The server retains a list of all of these and when an asteroid is changed in some way, this list will be updated and the server will notify the clients with the new list
# The clients will then Recive the update request and add/modify/delete the asteroid from the local scene
# CONSIDERATIONS AND POSSIBLE ISSUES
# Ideally only send newly updated asteroids to minimize network load
# If two players update the same asteroid at the same time, there might be issues
var Asteroids = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	if(is_multiplayer_authority()):
		AsteroidSpawner.inital_setup()
		
	for i in GameManager.Players:
		var current_player = player_scene.instantiate()
		current_player.name = str(GameManager.Players[i].id)
		add_child(current_player)
		current_player.add_to_group("Players")
		
		for spawn in get_tree().get_nodes_in_group("PlayerSpawns"):
			if(spawn.name == str(index)):
				current_player.global_position = spawn.global_position
		index+=1
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for player in get_tree().get_nodes_in_group("Players"):
		if(player.name == "1"):
			pass

