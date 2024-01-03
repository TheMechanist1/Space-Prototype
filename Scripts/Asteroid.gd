class_name Asteroid extends Activatable

@export var asteroid_scene = preload("res://Entities/Asteroid.tscn")
@export var asteroid_script = preload("res://Scripts/Asteroid.gd") # Use `load()` if you don't want to preload

@export var material1 = preload("res://Materials/Stone.material")
@export var material2 = preload("res://Materials/Copper.material")

@export var asteroid_type = "stone"
@export var asteroid_state = 3
@export var ore_amount = 0
var update_flag = false
var click_flag = false

@onready var collider = %CollisionShape3D
@onready var model = $Icosphere

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
	match(asteroid_state):
		1:
			scale_object(Vector3(1, 1, 1))
		2:
			scale_object(Vector3(3, 3, 3))
		3:
			scale_object(Vector3(10, 10, 10))
		_:
			print_debug("Bro what?")

func update_material():
	match(asteroid_type):
		"C-Type":
			pass
		"S-Type":
			pass
		"M-Type":
			pass
		_:
			pass
	
func scale_object(amount : Vector3):
	model.scale = amount
	collider.scale = amount

func split():
	if asteroid_state == 1 || click_flag: 
		return
	
	click_flag = true
	
	for i in range(3):
		var pos = self.global_position + Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
		if(is_multiplayer_authority()):
			AsteroidSpawner.create_asteroid({pos = pos, asteroid_type = self.asteroid_type, asteroid_state = self.asteroid_state - 1, ore_amount = self.ore_amount})
	
	if(is_multiplayer_authority()):
		AsteroidSpawner.remove_asteroid(get_parent_node_3d().name)
		
func activate() -> void:
	split()
