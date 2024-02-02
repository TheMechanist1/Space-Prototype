class_name Asteroid extends Activatable

var type : Array = ["C-Type", "S-Type", "M-Type"]
var ore : Array = ["Stone", "Auplnickel", "Kamacite", "Magalzinc"]

@export var asteroid_scene = preload("res://Entities/Asteroid.tscn")
@export var asteroid_script = preload("res://Scripts/Asteroid.gd")

@export var material1 = preload("res://Materials/Stone.material")
@export var material2 = preload("res://Materials/Auplnickel.material")               
@export var material3 = preload("res://Materials/Kamacite.material")
@export var material4 = preload("res://Materials/Magalzinc.material")

@export var asteroid_type = ""
@export var asteroid_ore = ""
@export var asteroid_state = 3
@export var ore_amount = 0
@export var ore_multiplier = 0

var update_flag = false
var click_flag = false

@onready var root_node = get_parent_node_3d()
@onready var collider = %CollisionShape3D
@onready var nav = %NavigationObstacle3D
@onready var model = %Icosphere

func _ready():
	update_flag = true

func _process(_delta):
	# If we have newer information, update it.
	# Flag allows us to save performance by only updating when we have new info
	if update_flag:
		update_scale()
		update_type()
		update_ore()
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

func update_type():
	match(asteroid_type):
		"C-Type":
			# Silicate Clay asteroid, minimal ore
			ore_multiplier = 0.5
		"S-Type":
			# Stoney asteroid, some ore
			ore_multiplier = 1
		"M-Type":
			# Mettalic asteroid, mostly ore
			ore_multiplier = 1.5
		_:
			pass

# Update the texture to match current ore type
func update_ore():
	match(asteroid_ore):
		"Stone":
			model.set_surface_override_material(0, material1)
		"Auplnickel":
			model.set_surface_override_material(0, material2)
		"Kamacite":
			model.set_surface_override_material(0, material3)
		"Magalzinc":
			model.set_surface_override_material(0, material4)
		_:
			pass
	
func scale_object(amount : Vector3):
	model.scale = amount
	collider.scale = amount
	#nav.scale = amount

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
					flags = { 
						ang = root_node.angular_velocity + Utility.random_vector3_uniform(-0.5, 0.5), 
						lin = root_node.linear_velocity + Utility.random_vector3_uniform(-0.5, 0.5),
						ore = self.asteroid_ore
					},
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
		flags = {
			ang = root_node.angular_velocity,
			lin = root_node.linear_velocity,
			ore = self.asteroid_ore,
		},
	}
	
# Abstract/Interface Functions
func activate(type) -> void:
	match(type["info"]):
		"Left Mouse Button":
			split()
		"Right Mouse Button":
			add_asteroid_to_player_stack(type)
		_:
			pass

