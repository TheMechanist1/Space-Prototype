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

@onready var root_node = get_parent_node_3d()
@onready var collider = %CollisionShape3D
@onready var model = $Icosphere

func _ready():
	update_flag = true

func _process(delta):
	#If we have newer information, update it.
	#Flag allows us to save performance by only updating when we have new info
	if update_flag:
		update_scale()
		root_node.mass = asteroid_state * asteroid_state * asteroid_state
		update_flag = false
		
func update_scale():
	match(asteroid_state):
		1:
			scale_object(Vector3(2, 2, 2))
		2:
			scale_object(Vector3(5, 5, 5))
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
		var pos = self.global_position + Utility.random_vector3_uniform(-0.5, 0.5)
		if(is_multiplayer_authority()):
			AsteroidSpawner.create_asteroid({
				pos = pos,
				asteroid_type = self.asteroid_type, 
				asteroid_state = self.asteroid_state - 1, 
				ore_amount = self.ore_amount, 
				angular = root_node.angular_velocity + Utility.random_vector3_uniform(-0.5, 0.5), 
				linear = root_node.linear_velocity + Utility.random_vector3_uniform(-0.5, 0.5)
				})
	
	if(is_multiplayer_authority()):
		AsteroidSpawner.remove_asteroid(root_node.name)
		
func add_asteroid_to_player_stack(type):
	if asteroid_state != 1:
		return
	var player_node = super.get_node_from_type(type)
	var data_to_push = convert_to_data()
	if(!player_node.asteroid_stack.has(data_to_push) && is_multiplayer_authority()):
		player_node.asteroid_stack.push(data_to_push)
		AsteroidSpawner.remove_asteroid(root_node.name)
		
func disable_collision():
	collider.disabled = true
	
func add_deletion_timer(time_until_deletion):
	var timer = Timer.new()
	timer.wait_time = time_until_deletion
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", _on_timer_timeout)
	timer.start()
	
func _on_timer_timeout():
	AsteroidSpawner.remove_asteroid(root_node.name)
	
func convert_to_data():
	return {
		pos = root_node.position,
		asteroid_type = self.asteroid_type,
		asteroid_state = self.asteroid_state,
		ore_amount = self.ore_amount,
		angular = root_node.angular_velocity,
		linear = root_node.linear_velocity
	}
	
#Abstract/Interface Functions
func activate(type) -> void:
	match(type["info"]):
		"Left Mouse Button":
			split()
		"Right Mouse Button":
			add_asteroid_to_player_stack(type)
		_:
			pass

