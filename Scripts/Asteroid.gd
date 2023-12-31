class_name Asteroid extends Node3D

@export var asteroid_scene = preload("res://Entities/Asteroid.tscn")
@export var asteroid_script = preload("res://Scripts/Asteroid.gd") # Use `load()` if you don't want to preload

@export var asteroid_type = "stone"
@export var asteroid_state = 3
@export var ore_amount = 0
var update_flag = false

@onready var collider = %CollisionShape3D
@onready var model1 = $Icosphere_1
@onready var model2 = $Icosphere_2
@onready var model3 = $Icosphere_2

func _ready():
	ore_amount = randf_range(10, 25)
	update_flag = true

func _process(delta):
	#If we have newer information, update it.
	#Flag allows us to save performance by only updating when we have new info
	if update_flag:
		update_scale()
		get_parent_node_3d().mass = asteroid_state * asteroid_state * asteroid_state
		
		update_flag = false
		
func update_scale():
	clear_model()
	match(asteroid_state):
		1:
			scale_object(Vector3(1, 1, 1))
			model3.visible = true
		2:
			scale_object(Vector3(3, 3, 3))
			model2.visible = true
		3:
			scale_object(Vector3(5, 5, 5))
			model1.visible = true
		_:
			print("Bro what?")
			
func clear_model():
	model1.visible = false
	model2.visible = false
	model3.visible = false
	
func scale_object(amount : Vector3):
	model1.scale = amount
	model2.scale = amount
	model3.scale = amount
	collider.scale = amount

func split():
	if asteroid_state == 1: 
		return

	for i in range(3):
		var pos = self.global_position + Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
		if(is_multiplayer_authority()):
			AsteroidSpawner.create_asteroid({pos = pos, asteroid_type = self.asteroid_type, asteroid_state = self.asteroid_state - 1, ore_amount = self.ore_amount})
		else:
			AsteroidSpawner.create_asteroid_rpc.rpc({pos = pos, asteroid_type = self.asteroid_type, asteroid_state = self.asteroid_state - 1, ore_amount = self.ore_amount})
	if(is_multiplayer_authority()):
		AsteroidSpawner.remove_asteroid(get_parent_node_3d().name)
	else:
		AsteroidSpawner.remove_asteroid_rpc.rpc(get_parent_node_3d().name)
		

