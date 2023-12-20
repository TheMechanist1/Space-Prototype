extends Node3D

@export var asteroid_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	for i in GameManager.Asteroids_To_Spawn:
		var current_asteroid = asteroid_scene.instantiate()
		add_child(current_asteroid)
		
		var pos = Vector3(randf_range(10, 50), randf_range(10, 50), randf_range(10, 50))
		current_asteroid.global_position = pos
		
		index+=1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
